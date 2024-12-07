//
//  EnvironmentValuesResolving.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 5/11/24.
//

import Foundation
import Combine

protocol EnvironmentValuesRepository {
    var resolvers: [AnyKeyPath: InstanceResolver] { get }
}

public protocol EnvironmentValuesResolving: AnyObject {
    
    func resolve<V>(_ keyPath: KeyPath<EnvironmentValues, V>) -> V
    
    func environmentValuePublisher<V>(for keyPath: KeyPath<EnvironmentValues, V>) -> AnyPublisher<V, Never>
    
    @discardableResult
    func environment<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue?,
        resolver: @escaping () -> V) -> Self
    
    @discardableResult
    func environment<S, V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        use soureKeyPath: WritableKeyPath<EnvironmentValues, S>) -> Self
}

public protocol EnvironmentLifeCycledValuesResolving: EnvironmentValuesResolving {
    
    @discardableResult
    func transient<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue?,
        resolver: @escaping () -> V) -> Self
    
    @discardableResult
    func weak<V: AnyObject>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue?,
        resolver: @escaping () -> V) -> Self
}

public extension EnvironmentValuesResolving {
    
    @inlinable
    @discardableResult
    func environment<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolver: @escaping () -> V) -> Self {
            environment(keyPath, resolveOn: nil, resolver: resolver)
        }
    
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

public extension EnvironmentLifeCycledValuesResolving {
    
    @inlinable
    @discardableResult
    func transient<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolver: @escaping () -> V) -> Self {
            transient(keyPath, resolveOn: nil, resolver: resolver)
        }
    
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
    func weak<V: AnyObject>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolver: @escaping () -> V) -> Self {
            weak(keyPath, resolveOn: nil, resolver: resolver)
        }
    
    @inlinable
    @discardableResult
    func weak<V: AnyObject>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @autoclosure @escaping () -> V) -> Self {
            weak(keyPath, resolveOn: queue, resolver: value)
        }
}
