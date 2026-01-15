//
//  GlobalValues.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 30/05/25.
//

import Foundation
import Combine
import Chary

/// A struct that provides global access to environment values using dynamic member lookup.
/// 
/// `GlobalValues` is the central registry for all global environment values in your application.
/// It supports different resolution strategies (singleton, transient, weak) and dependency injection.
/// 
/// Example:
/// ```swift
/// // Define a global value
/// extension GlobalValues {
///     @GlobalEntry var myService: MyService = MyService()
/// }
/// 
/// // Access it
/// let service = GlobalValues.myService
/// ```
@dynamicMemberLookup
public struct GlobalValues: @unchecked Sendable {
    
    private static let accessQueue = DispatchQueue(label: "GlobalValues.accessQueue", attributes: .concurrent)
    
    /// A dictionary mapping key paths to their instance resolvers.
    private static var underlyingResolvers: [PartialKeyPath<GlobalValues>: InstanceResolver] = [:]
    
    /// A subject that emits when resolvers are assigned to key paths.
    /// This can be used to observe changes to global values.
    private(set) static var assignedResolversSubject: PassthroughSubject<(PartialKeyPath<GlobalValues>, InstanceResolver), Never> = .init()
    
    /// Resets all global values by clearing resolvers and creating a new subject.
    /// 
    /// This is primarily useful for testing to ensure a clean state.
    static func reset() {
        GlobalValues.atomicWrite {
            GlobalValues.underlyingResolvers.removeAll()
            GlobalValues.assignedResolversSubject = .init()
        }
    }
    
    /// Gets the optional value for a given key path.
    /// 
    /// - Parameter key: The key path to the value.
    /// - Returns: The resolved value, or `nil` if no resolver is registered.
    public subscript<Value>(_ key: KeyPath<GlobalValues, Value>) -> Value? {
        GlobalValues.atomicRead {
            return GlobalValues.underlyingResolvers[key]?.resolve(for: Value.self)
        }
    }
    
    /// Gets the value for a given key path using dynamic member lookup.
    /// 
    /// - Parameter keyPath: The key path to the value.
    /// - Returns: The resolved value.
    public static subscript<Value>(dynamicMember keyPath: KeyPath<GlobalValues, Value>) -> Value {
        GlobalValues()[keyPath: keyPath]
    }
    
    /// Returns a publisher that emits when the value for the given key path changes.
    /// 
    /// - Parameter keyPath: The key path to observe.
    /// - Returns: A publisher that emits the current value and any future updates.
    static func publisher<Value>(for keyPath: KeyPath<GlobalValues, Value>) -> AnyPublisher<Value, Never> {
        assignedResolversSubject
            .filter { $0.0 == keyPath }
            .compactMap { $0.1.resolve(for: Value.self) }
            .eraseToAnyPublisher()
    }
    
    /// Assigns a singleton instance resolver to the given key path.
    /// 
    /// The value is created once and reused for all subsequent accesses.
    /// 
    /// - Parameters:
    ///   - keyPath: The key path to assign the resolver to.
    ///   - queue: An optional dispatch queue to resolve the value on. If `nil`, the value is resolved on the calling thread.
    ///   - resolver: A closure that creates the value.
    /// - Returns: `GlobalValues.Type` for method chaining.
    @discardableResult
    public static func environment<Value>(
        _ keyPath: KeyPath<GlobalValues, Value>,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> Value) -> GlobalValues.Type {
            assign(resolver: SingletonInstanceResolver(queue: queue, resolver: resolver), to: keyPath)
            return GlobalValues.self
        }
    
    /// Assigns a transient instance resolver to the given key path.
    /// 
    /// A new value is created each time it is accessed.
    /// 
    /// - Parameters:
    ///   - keyPath: The key path to assign the resolver to.
    ///   - queue: An optional dispatch queue to resolve the value on. If `nil`, the value is resolved on the calling thread.
    ///   - resolver: A closure that creates the value.
    /// - Returns: `GlobalValues.Type` for method chaining.
    @discardableResult
    public static func transient<Value>(
        _ keyPath: KeyPath<GlobalValues, Value>,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> Value) -> GlobalValues.Type {
            assign(resolver: TransientInstanceResolver(queue: queue, resolver: resolver), to: keyPath)
            return GlobalValues.self
        }
    
    /// Assigns a weak instance resolver to the given key path.
    /// 
    /// The value is held weakly and a new instance is created when the old one is deallocated.
    /// The resolver must return a reference type; if you use a protocol type, make it class-bound or ensure the concrete type is a class.
    /// 
    /// - Parameters:
    ///   - keyPath: The key path to assign the resolver to.
    ///   - queue: An optional dispatch queue to resolve the value on. If `nil`, the value is resolved on the calling thread.
    ///   - resolver: A closure that creates the value.
    /// - Returns: `GlobalValues.Type` for method chaining.
    @discardableResult
    public static func weak<Value>(
        _ keyPath: KeyPath<GlobalValues, Value>,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> Value) -> GlobalValues.Type {
            assign(resolver: WeakInstanceResolver(queue: queue, resolver: resolver), to: keyPath)
            return GlobalValues.self
        }
    
    /// Creates a dependency relationship where `keyPath` depends on `sourceKeyPath`.
    /// 
    /// When `keyPath` is accessed, it will resolve the value from `sourceKeyPath` and cast it to `Value`.
    /// This is useful for creating derived or dependent values.
    /// 
    /// - Parameters:
    ///   - sourceKeyPath: The key path to the source value.
    ///   - keyPath: The key path to assign the dependency to.
    /// - Returns: `GlobalValues.Type` for method chaining.
    @discardableResult
    public static func use<Source, Value>(
        _ sourceKeyPath: KeyPath<GlobalValues, Source>,
        for keyPath: KeyPath<GlobalValues, Value>) -> GlobalValues.Type {
            assign(
                resolver: OptionalTransientInstanceResolver<Value>(queue: nil) {
                    let resolver = GlobalValues.atomicRead {
                        GlobalValues.underlyingResolvers[sourceKeyPath]
                    }
                    return resolver?.resolve(for: Value.self)
                },
                to: keyPath
            )
            return self
        }
    
    /// Assigns a resolver to a key path.
    /// 
    /// This is a private helper method used by the public assignment methods.
    /// 
    /// - Parameters:
    ///   - resolver: The resolver to assign.
    ///   - keyPath: The key path to assign the resolver to.
    private static func assign(resolver: InstanceResolver, to keyPath: PartialKeyPath<GlobalValues>) {
        atomicWrite {
            GlobalValues.underlyingResolvers[keyPath] = resolver
            GlobalValues.assignedResolversSubject.send((keyPath, resolver))
        }
    }
    
    /// Reads a value atomically using a concurrent dispatch queue.
    /// 
    /// This ensures thread-safe access to the global values registry.
    /// 
    /// - Parameter block: A closure that reads the value.
    /// - Returns: The result of the closure.
    public static func atomicRead<Result>(_ block: () throws -> Result) rethrows -> Result {
        try accessQueue.safeSync {
            try block()
        }
    }
    
    private static func atomicWrite<Result>(_ block: () throws -> Result) rethrows -> Result {
        try accessQueue.safeSync(flags: .barrier) {
            try block()
        }
    }
}

// MARK: GlobalValues + Environment

public extension GlobalValues {
    
    /// Convenience overload that uses autoclosure for the value.
    /// 
    /// - Parameters:
    ///   - keyPath: The key path to assign the resolver to.
    ///   - queue: An optional dispatch queue to resolve the value on.
    ///   - value: The value to use (autoclosure).
    ///   - note: The value must be a reference type; class-bound protocols are recommended.
    /// - Returns: `GlobalValues.Type` for method chaining.
    @inlinable
    @discardableResult
    static func environment<Value>(
        _ keyPath: KeyPath<GlobalValues, Value>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @autoclosure @escaping () -> Value) -> GlobalValues.Type {
            environment(keyPath, resolveOn: queue, resolver: value)
        }
}

// MARK: GlobalValues + Use

public extension GlobalValues {
    
    /// Convenience overload for setting up multiple dependencies at once.
    /// 
    /// - Parameters:
    ///   - sourceKeyPath: The key path to the source value.
    ///   - keyPath1: The first key path to assign the dependency to.
    ///   - keyPath2: The second key path to assign the dependency to.
    /// - Returns: `GlobalValues.Type` for method chaining.
    @inlinable
    @discardableResult
    static func use<Source, Value1, Value2>(
        _ sourceKeyPath: KeyPath<GlobalValues, Source>,
        for keyPath1: KeyPath<GlobalValues, Value1>,
        _ keyPath2: KeyPath<GlobalValues, Value2>) -> GlobalValues.Type {
            use(sourceKeyPath, for: keyPath1)
                .use(sourceKeyPath, for: keyPath2)
        }
    
    /// Convenience overload for setting up multiple dependencies at once.
    /// 
    /// - Parameters:
    ///   - sourceKeyPath: The key path to the source value.
    ///   - keyPath1: The first key path to assign the dependency to.
    ///   - keyPath2: The second key path to assign the dependency to.
    ///   - keyPath3: The third key path to assign the dependency to.
    /// - Returns: `GlobalValues.Type` for method chaining.
    @inlinable
    @discardableResult
    static func use<Source, Value1, Value2, Value3>(
        _ sourceKeyPath: KeyPath<GlobalValues, Source>,
        for keyPath1: KeyPath<GlobalValues, Value1>,
        _ keyPath2: KeyPath<GlobalValues, Value2>,
        _ keyPath3: KeyPath<GlobalValues, Value3>) -> GlobalValues.Type {
            use(sourceKeyPath, for: keyPath1)
                .use(sourceKeyPath, for: keyPath2)
                .use(sourceKeyPath, for: keyPath3)
        }
}

// MARK: GlobalValues + Transient & Weak

public extension GlobalValues {
    
    /// Convenience overload that uses autoclosure for the value.
    /// 
    /// - Parameters:
    ///   - keyPath: The key path to assign the resolver to.
    ///   - queue: An optional dispatch queue to resolve the value on.
    ///   - value: The value to use (autoclosure).
    /// - Returns: `GlobalValues.Type` for method chaining.
    @inlinable
    @discardableResult
    static func transient<Value>(
        _ keyPath: KeyPath<GlobalValues, Value>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @autoclosure @escaping () -> Value) -> GlobalValues.Type {
            transient(keyPath, resolveOn: queue, resolver: value)
        }
    
    /// Convenience overload that uses autoclosure for the value.
    /// 
    /// - Parameters:
    ///   - keyPath: The key path to assign the resolver to.
    ///   - queue: An optional dispatch queue to resolve the value on.
    ///   - value: The value to use (autoclosure).
    /// - Returns: `GlobalValues.Type` for method chaining.
    @inlinable
    @discardableResult
    static func weak<Value>(
        _ keyPath: KeyPath<GlobalValues, Value>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @autoclosure @escaping () -> Value) -> GlobalValues.Type {
            weak(keyPath, resolveOn: queue, resolver: value)
        }
}
