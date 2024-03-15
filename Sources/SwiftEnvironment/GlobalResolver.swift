//
//  GlobalEnv.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 14/3/24.
//

import Foundation

public struct GlobalResolver {
    
    @discardableResult
    public static func environment<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        _ value: V) -> EnvironmentValuesResolver {
            EnvironmentValuesResolver.global.environment(keyPath, value)
        }
    
    @inlinable
    @discardableResult
    public static func singleton<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @escaping @autoclosure () -> V) -> EnvironmentValuesResolver {
            singleton(keyPath, resolveOn: queue, resolver: value)
        }
    
    @discardableResult
    public static func singleton<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> V) -> EnvironmentValuesResolver {
            EnvironmentValuesResolver.global.singleton(keyPath, resolveOn: queue, resolver)
        }
    
    @inlinable
    @discardableResult
    public static func transient<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @escaping @autoclosure () -> V) -> EnvironmentValuesResolver {
            transient(keyPath, resolveOn: queue, resolver: value)
        }
    
    @discardableResult
    public static func transient<V>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> V) -> EnvironmentValuesResolver {
            EnvironmentValuesResolver.global.transient(keyPath, resolveOn: queue, resolver)
        }
    
    @inlinable
    @discardableResult
    public static func weak<V: AnyObject>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        _ value: @escaping @autoclosure () -> V) -> EnvironmentValuesResolver {
            weak(keyPath, resolveOn: queue, resolver: value)
        }
    
    @discardableResult
    public static func weak<V: AnyObject>(
        _ keyPath: WritableKeyPath<EnvironmentValues, V>,
        resolveOn queue: DispatchQueue? = nil,
        resolver: @escaping () -> V) -> EnvironmentValuesResolver {
            EnvironmentValuesResolver.global.weak(keyPath, resolveOn: queue, resolver)
        }
}
