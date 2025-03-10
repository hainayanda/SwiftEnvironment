//
//  SwiftEnvironmentValues.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 10/03/25.
//

import Foundation
import Combine

// MARK: EnvironmentValues + global

extension EnvironmentValues {
    public internal(set) static var global: SwiftEnvironmentValues = SwiftEnvironmentValues()
}

// MARK: SwiftEnvironmentValues

@dynamicMemberLookup
public final class SwiftEnvironmentValues {
    
    private let defaultEnvironmentValues: EnvironmentValues = EnvironmentValues()
    private(set) var underlyingResolvers: [AnyKeyPath: InstanceResolver] = [:]
    private(set) var assignedResolversSubject: PassthroughSubject<(AnyKeyPath, InstanceResolver), Never> = .init()
    
    public subscript<V>(dynamicMember keyPath: WritableKeyPath<EnvironmentValues, V>) -> V {
        underlyingResolvers[keyPath]?.resolve(for: V.self) ?? defaultEnvironmentValues[keyPath: keyPath]
    }
    
    public init() { }
    
    public func publisher<Value>(for keyPath: WritableKeyPath<EnvironmentValues, Value>) -> AnyPublisher<Value, Never> {
        assignedResolversSubject
            .filter { $0.0 == keyPath }
            .compactMap { $0.1.resolve(for: Value.self) }
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    public func environment<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> V) -> Self {
            assign(resolver: SingletonInstanceResolver(queue: queue, resolver: resolver), to: keyPath)
            return self
        }
    
    @discardableResult
    public func transient<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> V) -> Self {
            assign(resolver: TransientInstanceResolver(queue: queue, resolver: resolver), to: keyPath)
            return self
        }
    
    @discardableResult
    public func weak<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> V) -> Self {
            assign(resolver: WeakInstanceResolver(queue: queue, resolver: resolver), to: keyPath)
            return self
        }
    
    @discardableResult
    public func environment<S, V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        use soureKeyPath: WritableKeyPath<EnvironmentValues, S>) -> Self {
            assign(
                resolver: TransientInstanceResolver<V>(queue: nil) { [unowned self] in
                    (self[dynamicMember: soureKeyPath] as? V) ?? self.defaultEnvironmentValues[keyPath: keyPath]
                },
                to: keyPath
            )
            return self
        }
    
    private func assign(resolver: InstanceResolver, to keyPath: AnyKeyPath) {
        underlyingResolvers[keyPath] = resolver
        assignedResolversSubject.send((keyPath, resolver))
    }
}

// MARK: GlobalEnvironmentValues + Environment

public extension SwiftEnvironmentValues {
    
    @inlinable
    @discardableResult
    func environment<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @autoclosure @escaping () -> V) -> Self {
            environment(keyPath, resolveOn: queue, resolver: value)
        }
    
    @inlinable
    @discardableResult
    func environment<S, V1, V2>(
        _ keyPath1: WritableKeyPath<EnvironmentValues, V1>,
        _ keyPath2: WritableKeyPath<EnvironmentValues, V2>,
        use soureKeyPath: WritableKeyPath<EnvironmentValues, S>) -> Self {
            environment(keyPath1, use: soureKeyPath)
                .environment(keyPath2, use: soureKeyPath)
        }
    
    @inlinable
    @discardableResult
    func environment<S, V1, V2, V3>(
        _ keyPath1: WritableKeyPath<EnvironmentValues, V1>,
        _ keyPath2: WritableKeyPath<EnvironmentValues, V2>,
        _ keyPath3: WritableKeyPath<EnvironmentValues, V3>,
        use soureKeyPath: WritableKeyPath<EnvironmentValues, S>) -> Self {
            environment(keyPath1, use: soureKeyPath)
                .environment(keyPath2, use: soureKeyPath)
                .environment(keyPath3, use: soureKeyPath)
        }
}

// MARK: GlobalEnvironmentValues + Transient & Weak

public extension SwiftEnvironmentValues {
    
    @inlinable
    @discardableResult
    func transient<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @autoclosure @escaping () -> V) -> Self {
            transient(keyPath, resolveOn: queue, resolver: value)
        }
    
    @inlinable
    @discardableResult
    func weak<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @autoclosure @escaping () -> V) -> Self {
            weak(keyPath, resolveOn: queue, resolver: value)
        }
}
