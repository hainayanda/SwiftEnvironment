//
//  GlobalEnvironment.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 14/3/24.
//

import Foundation

@propertyWrapper 
public final class GlobalEnvironment<Value> {
    
    private let resolver: EnvironmentValuesResolver
    private let keyPath: WritableKeyPath<EnvironmentValues, Value>
    private var injectedValue: Value?
    
    public var wrappedValue: Value {
        get {
            injectedValue ?? resolver.resolve(keyPath)
        }
        set {
            injectedValue = newValue
        }
    }
    
    public init(_ keyPath: WritableKeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
        self.resolver = EnvironmentValuesResolver.global
    }
}
