//
//  GlobalValues.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 30/05/25.
//

import Foundation
import Combine
import Chary

@dynamicMemberLookup
public struct GlobalValues: @unchecked Sendable {
    
    private static let accessQueue = DispatchQueue(label: "GlobalValues.accessQueue", attributes: .concurrent)
    
    private static var underlyingResolvers: [PartialKeyPath<GlobalValues>: InstanceResolver] = [:]
    private(set) static var assignedResolversSubject: PassthroughSubject<(PartialKeyPath<GlobalValues>, InstanceResolver), Never> = .init()
    
    static func reset() {
        GlobalValues.atomicWrite {
            GlobalValues.underlyingResolvers.removeAll()
            GlobalValues.assignedResolversSubject = .init()
        }
    }
    
    public subscript<Value>(_ key: KeyPath<GlobalValues, Value>) -> Value? {
        GlobalValues.atomicRead {
            return GlobalValues.underlyingResolvers[key]?.resolve(for: Value.self)
        }
    }
    
    public static subscript<Value>(dynamicMember keyPath: KeyPath<GlobalValues, Value>) -> Value {
        GlobalValues()[keyPath: keyPath]
    }
    
    static func publisher<Value>(for keyPath: KeyPath<GlobalValues, Value>) -> AnyPublisher<Value, Never> {
        assignedResolversSubject
            .filter { $0.0 == keyPath }
            .compactMap { $0.1.resolve(for: Value.self) }
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    public static func environment<Value>(
        _ keyPath: KeyPath<GlobalValues, Value>,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> Value) -> GlobalValues.Type {
            assign(resolver: SingletonInstanceResolver(queue: queue, resolver: resolver), to: keyPath)
            return GlobalValues.self
        }
    
    @discardableResult
    public static func transient<Value>(
        _ keyPath: KeyPath<GlobalValues, Value>,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> Value) -> GlobalValues.Type {
            assign(resolver: TransientInstanceResolver(queue: queue, resolver: resolver), to: keyPath)
            return GlobalValues.self
        }
    
    @discardableResult
    public static func weak<Value>(
        _ keyPath: KeyPath<GlobalValues, Value>,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> Value) -> GlobalValues.Type {
            assign(resolver: WeakInstanceResolver(queue: queue, resolver: resolver), to: keyPath)
            return GlobalValues.self
        }
    
    @discardableResult
    public static func use<Source, Value>(
        _ sourceKeyPath: KeyPath<GlobalValues, Source>,
        for keyPath: KeyPath<GlobalValues, Value>) -> GlobalValues.Type {
            assign(
                resolver: OptionalTransientInstanceResolver<Value>(queue: nil) {
                    return GlobalValues.underlyingResolvers[sourceKeyPath]?.resolve(for: Value.self)
                },
                to: keyPath
            )
            return self
        }
    
    private static func assign(resolver: InstanceResolver, to keyPath: PartialKeyPath<GlobalValues>) {
        atomicWrite {
            GlobalValues.underlyingResolvers[keyPath] = resolver
            GlobalValues.assignedResolversSubject.send((keyPath, resolver))
        }
    }
    
    private static func atomicRead<Result>(_ block: () throws -> Result) rethrows -> Result {
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
    
    @inlinable
    @discardableResult
    static func use<Source, Value1, Value2>(
        _ sourceKeyPath: KeyPath<GlobalValues, Source>,
        for keyPath1: KeyPath<GlobalValues, Value1>,
        _ keyPath2: KeyPath<GlobalValues, Value2>) -> GlobalValues.Type {
            use(sourceKeyPath, for: keyPath1)
                .use(sourceKeyPath, for: keyPath2)
        }
    
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
    
    @inlinable
    @discardableResult
    static func transient<Value>(
        _ keyPath: KeyPath<GlobalValues, Value>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @autoclosure @escaping () -> Value) -> GlobalValues.Type {
            transient(keyPath, resolveOn: queue, resolver: value)
        }
    
    @inlinable
    @discardableResult
    static func weak<Value>(
        _ keyPath: KeyPath<GlobalValues, Value>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @autoclosure @escaping () -> Value) -> GlobalValues.Type {
            weak(keyPath, resolveOn: queue, resolver: value)
        }
}
