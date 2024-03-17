//
//  EnvironmentValuesResolver.swift
//  
//
//  Created by Nayanda Haberty on 14/3/24.
//

import Foundation

public class EnvironmentValuesResolver {
    
    static var global: EnvironmentValuesResolver = EnvironmentValuesResolver()
    
    private var environmentValues: EnvironmentValues
    private var resolvers: [AnyKeyPath: InstanceResolver]
    
    init(resolvers: [AnyKeyPath: InstanceResolver] = [:]) {
        self.environmentValues = EnvironmentValues()
        self.resolvers = resolvers
    }
    
    func resolve<V>(_ keyPath: KeyPath<EnvironmentValues, V>) -> V {
        resolvers[keyPath]?.resolve(for: V.self) ?? environmentValues[keyPath: keyPath]
    }
    
    @discardableResult
    public func environment<S, V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        use soureKeyPath: WritableKeyPath<EnvironmentValues, S>) -> EnvironmentValuesResolver {
            resolvers[keyPath] = TransientInstanceResolver<V>(queue: nil) { [unowned self] in
                (self.resolve(soureKeyPath) as? V) ?? self.environmentValues[keyPath: keyPath]
            }
            return self
        }
    
    @discardableResult
    public func environment<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @escaping () -> V) -> EnvironmentValuesResolver {
            resolvers[keyPath] = SingletonInstanceResolver(queue: queue, resolver: value)
            return self
        }
    
    @discardableResult
    public func transient<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @escaping () -> V) -> EnvironmentValuesResolver {
            resolvers[keyPath] = TransientInstanceResolver(queue: queue, resolver: value)
            return self
        }
    
    @discardableResult
    public func weak<V: AnyObject>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @escaping () -> V) -> EnvironmentValuesResolver {
            resolvers[keyPath] = WeakInstanceResolver(queue: queue, resolver: value)
            return self
        }
}

extension EnvironmentValuesResolver {
    
    @inlinable
    @discardableResult
    public func environment<S, V1, V2>(
        _ keyPath1: WritableKeyPath<EnvironmentValues, V1>,
        _ keyPath2: WritableKeyPath<EnvironmentValues, V2>,
        use soureKeyPath: WritableKeyPath<EnvironmentValues, S>) -> EnvironmentValuesResolver {
            environment(keyPath1, use: soureKeyPath)
                .environment(keyPath2, use: soureKeyPath)
        }
    
    @inlinable
    @discardableResult
    public func environment<S, V1, V2, V3>(
        _ keyPath1: WritableKeyPath<EnvironmentValues, V1>,
        _ keyPath2: WritableKeyPath<EnvironmentValues, V2>,
        _ keyPath3: WritableKeyPath<EnvironmentValues, V3>,
        use soureKeyPath: WritableKeyPath<EnvironmentValues, S>) -> EnvironmentValuesResolver {
            environment(keyPath1, use: soureKeyPath)
                .environment(keyPath2, use: soureKeyPath)
                .environment(keyPath3, use: soureKeyPath)
        }
}
