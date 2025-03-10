//
//  SwiftUIEnvironment+Extensions.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 10/03/25.
//

import SwiftUI

public extension Scene {
    func defaultEnvironment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, from source: SwiftEnvironmentValues) -> some Scene {
        environment(keyPath, source[dynamicMember: keyPath])
    }
}

public extension View {
    func defaultEnvironment<V>(_ keyPath: WritableKeyPath<EnvironmentValues, V>, from source: SwiftEnvironmentValues) -> some View {
        environment(keyPath, source[dynamicMember: keyPath])
    }
}
