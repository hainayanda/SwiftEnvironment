//
//  GlobalValues.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 30/05/25.
//

import Foundation
import SwiftUICore
import Combine

@dynamicMemberLookup
public struct GlobalValues: @unchecked Sendable {
    
    private static var globalSemaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    private static var underlyingResolvers: [PartialKeyPath<GlobalValues>: InstanceResolver] = [:]
    private(set) static var assignedResolversSubject: PassthroughSubject<(PartialKeyPath<GlobalValues>, InstanceResolver), Never> = .init()
    
    static func reset() {
        GlobalValues.atomicAccess {
            GlobalValues.underlyingResolvers.removeAll()
            GlobalValues.assignedResolversSubject = .init()
        }
    }
    
    public subscript<Value>(_ key: KeyPath<GlobalValues, Value>) -> Value? {
        GlobalValues.atomicAccess {
            return GlobalValues.underlyingResolvers[key]?.resolve(for: Value.self)
        }
    }
    
    static subscript<Value>(dynamicMember keyPath: KeyPath<GlobalValues, Value>) -> Value {
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
            GlobalValues.atomicAccess {
                assign(resolver: SingletonInstanceResolver(queue: queue, resolver: resolver), to: keyPath)
                return GlobalValues.self
            }
        }
    
    @discardableResult
    public static func transient<Value>(
        _ keyPath: KeyPath<GlobalValues, Value>,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> Value) -> GlobalValues.Type {
            GlobalValues.atomicAccess {
                assign(resolver: TransientInstanceResolver(queue: queue, resolver: resolver), to: keyPath)
                return GlobalValues.self
            }
        }
    
    @discardableResult
    public static func weak<Value>(
        _ keyPath: KeyPath<GlobalValues, Value>,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> Value) -> GlobalValues.Type {
            GlobalValues.atomicAccess {
                assign(resolver: WeakInstanceResolver(queue: queue, resolver: resolver), to: keyPath)
                return GlobalValues.self
            }
        }
    
    @discardableResult
    public static func use<Source, Value>(
        _ soureKeyPath: KeyPath<GlobalValues, Source>,
        for keyPath: KeyPath<GlobalValues, Value>) -> GlobalValues.Type {
            let defaultValue = GlobalValues()[keyPath: keyPath]
            GlobalValues.atomicAccess {
                assign(
                    resolver: TransientInstanceResolver<Value>(queue: nil) {
                        return GlobalValues.underlyingResolvers[soureKeyPath]?.resolve(for: Value.self) ?? defaultValue
                    },
                    to: keyPath
                )
            }
            return self
        }
    
    // should be called inside atomicAccess closure
    private static func assign(resolver: InstanceResolver, to keyPath: PartialKeyPath<GlobalValues>) {
        GlobalValues.underlyingResolvers[keyPath] = resolver
        GlobalValues.assignedResolversSubject.send((keyPath, resolver))
    }
    
    private static func atomicAccess<Result>(_ block: () throws -> Result) rethrows -> Result {
        GlobalValues.globalSemaphore.wait()
        defer { GlobalValues.globalSemaphore.signal() }
        return try block()
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
        _ soureKeyPath: KeyPath<GlobalValues, Source>,
        for keyPath1: KeyPath<GlobalValues, Value1>,
        _ keyPath2: KeyPath<GlobalValues, Value2>) -> GlobalValues.Type {
            use(soureKeyPath, for: keyPath1)
                .use(soureKeyPath, for: keyPath2)
        }
    
    @inlinable
    @discardableResult
    static func use<Source, Value1, Value2, Value3>(
        _ soureKeyPath: KeyPath<GlobalValues, Source>,
        for keyPath1: KeyPath<GlobalValues, Value1>,
        _ keyPath2: KeyPath<GlobalValues, Value2>,
        _ keyPath3: KeyPath<GlobalValues, Value3>) -> GlobalValues.Type {
            use(soureKeyPath, for: keyPath1)
                .use(soureKeyPath, for: keyPath2)
                .use(soureKeyPath, for: keyPath3)
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
