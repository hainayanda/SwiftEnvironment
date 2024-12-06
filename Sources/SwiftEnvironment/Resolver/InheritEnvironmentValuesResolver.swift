//
//  InheritEnvironmentValuesResolver.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 5/11/24.
//

import Foundation

public final class InheritEnvironmentValuesResolver: EnvironmentValuesResolver {
    
    private var parentGetter: () -> EnvironmentValuesResolving?
    var parent: EnvironmentValuesResolving? {
        parentGetter()
    }
    
    override var resolvers: [AnyKeyPath: InstanceResolver] {
        let parentResolvers = (parent as? EnvironmentValuesRepository)?.resolvers ?? [:]
        return underlyingResolvers.reduce(into: parentResolvers) { partialResult, pair in
            partialResult[pair.key] = pair.value
        }
    }
    
    init(resolvers: [AnyKeyPath: InstanceResolver] = [:], parent: @escaping () -> EnvironmentValuesResolving?) {
        self.parentGetter = parent
        super.init(resolvers: resolvers)
    }
    
    public override func resolve<V>(_ keyPath: KeyPath<EnvironmentValues, V>) -> V {
        underlyingResolvers[keyPath]?.resolve(for: V.self) ?? defaultResolve(keyPath)
    }
    
    private func defaultResolve<V>(_ keyPath: KeyPath<EnvironmentValues, V>) -> V {
        parent?.resolve(keyPath) ?? defaultEnvironmentValues[keyPath: keyPath]
    }
}
