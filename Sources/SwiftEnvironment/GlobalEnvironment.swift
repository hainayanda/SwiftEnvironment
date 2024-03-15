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
    private let keyPath: KeyPath<EnvironmentValues, Value>
    
    public private(set) lazy var wrappedValue: Value = resolver.resolve(keyPath)
    
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
        self.resolver = EnvironmentValuesResolver.global
    }
}
