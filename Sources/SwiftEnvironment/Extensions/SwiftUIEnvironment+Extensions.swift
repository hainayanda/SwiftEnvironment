//
//  SwiftUIEnvironment+Extensions.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 10/03/25.
//

import SwiftUI

public extension Scene {
    func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, from source: GlobalEnvironmentValues) -> some Scene {
        environment(keyPath, source[dynamicMember: keyPath])
    }
}

public extension View {
    func environment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, from source: GlobalEnvironmentValues) -> some View {
        environment(keyPath, source[dynamicMember: keyPath])
    }
}
