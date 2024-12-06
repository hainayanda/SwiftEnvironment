//
//  ViewEnvironment.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 5/11/24.
//

import Foundation

protocol EnvironmentValuesResolverHost: EnvironmentValuesResolving {
    var environmentValuesResolver: EnvironmentValuesResolving { get }
}

extension EnvironmentValuesResolverHost {
    
    public func resolve<V>(_ keyPath: KeyPath<EnvironmentValues, V>) -> V {
        environmentValuesResolver.resolve(keyPath)
    }
    
    @discardableResult
    public func environment<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue?,
        resolver: @escaping () -> V) -> Self {
            environmentValuesResolver.environment(keyPath, resolveOn: queue, resolver: resolver)
            return self
        }
    
    @discardableResult
    public func environment<S, V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        use soureKeyPath: WritableKeyPath<EnvironmentValues, S>) -> Self {
            environmentValuesResolver.environment(keyPath, use: soureKeyPath)
            return self
        }
}
