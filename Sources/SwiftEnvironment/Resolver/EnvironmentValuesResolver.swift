//
//  EnvironmentValuesResolver.swift
//
//
//  Created by Nayanda Haberty on 14/3/24.
//

import Foundation
import Combine

public class EnvironmentValuesResolver: EnvironmentLifeCycledValuesResolving, EnvironmentValuesRepository {
    
    static var global: EnvironmentValuesResolver = EnvironmentValuesResolver()
    
    let defaultEnvironmentValues: EnvironmentValues
    private(set) var underlyingResolvers: [AnyKeyPath: InstanceResolver]
    var resolvers: [AnyKeyPath: InstanceResolver] { underlyingResolvers }
    var resolverAssignSubject: PassthroughSubject<(AnyKeyPath, InstanceResolver), Never> = .init()
    
    init(resolvers: [AnyKeyPath: InstanceResolver] = [:]) {
        self.defaultEnvironmentValues = EnvironmentValues()
        self.underlyingResolvers = resolvers
    }
    
    public func resolve<V>(_ keyPath: KeyPath<EnvironmentValues, V>) -> V {
        underlyingResolvers[keyPath]?.resolve(for: V.self) ?? defaultEnvironmentValues[keyPath: keyPath]
    }
    
    public func environmentValuePublisher<V>(for keyPath: KeyPath<EnvironmentValues, V>) -> AnyPublisher<V, Never> {
        resolverAssignSubject
            .filter { $0.0 == keyPath }
            .compactMap { $0.1.resolve(for: V.self) }
            .eraseToAnyPublisher()
    }
    
    @discardableResult
    public func environment<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue?,
        resolver: @escaping () -> V) -> Self {
            assign(resolver: SingletonInstanceResolver(queue: queue, resolver: resolver), to: keyPath)
            return self
        }
    
    @discardableResult
    public func transient<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue?,
        resolver: @escaping () -> V) -> Self {
            assign(resolver: TransientInstanceResolver(queue: queue, resolver: resolver), to: keyPath)
            return self
        }
    
    @discardableResult
    public func weak<V: AnyObject>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue?,
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
                    (self.resolve(soureKeyPath) as? V) ?? self.defaultEnvironmentValues[keyPath: keyPath]
                },
                to: keyPath
            )
            return self
        }
    
    private func assign(resolver: InstanceResolver, to keyPath: AnyKeyPath) {
        underlyingResolvers[keyPath] = resolver
        resolverAssignSubject.send((keyPath, resolver))
    }
}
