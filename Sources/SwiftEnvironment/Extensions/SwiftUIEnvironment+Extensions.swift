//
//  SwiftUIEnvironment+Extensions.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 10/03/25.
//

import SwiftUI

public extension Scene {
    nonisolated func defaultEnvironment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, from source: SwiftEnvironmentValues) -> some Scene {
        environment(keyPath, source[dynamicMember: keyPath])
    }
    
    nonisolated func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V, injectTo source: SwiftEnvironmentValues) -> some Scene {
        source.environment(keyPath, value)
        return environment(keyPath, value)
    }
    
    nonisolated func weakEnvironment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V, injectTo source: SwiftEnvironmentValues) -> some Scene {
        source.weak(keyPath, value)
        return environment(keyPath, value)
    }
}

public extension View {
    nonisolated func defaultEnvironment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, from source: SwiftEnvironmentValues) -> some View {
        environment(keyPath, source[dynamicMember: keyPath])
    }
    
    nonisolated func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V, injectTo source: SwiftEnvironmentValues) -> some View {
        source.environment(keyPath, value)
        return environment(keyPath, value)
    }
    
    nonisolated func weakEnvironment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, _ value: V, injectTo source: SwiftEnvironmentValues) -> some View {
        source.weak(keyPath, value)
        return environment(keyPath, value)
    }
}
