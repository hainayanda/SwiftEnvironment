//
//  GlobalEnvironment.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 14/3/24.
//

import Foundation
import Combine
import SwiftUICore

@propertyWrapper
public final class GlobalEnvironment<Value>: DynamicProperty, PropertyWrapperDiscardable {
    
    private let globalEnvironmentValues = EnvironmentValues.global
    private let keyPath: WritableKeyPath<EnvironmentValues, Value>
    private var observerCancellable: AnyCancellable?
    
    @State private var injectedValue: Value?
    @State private var resolvedValue: Value
    public var wrappedValue: Value {
        get { injectedValue ?? resolvedValue }
        set { injectedValue = newValue }
    }
    
    public init(_ keyPath: WritableKeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
        self.resolvedValue = globalEnvironmentValues[dynamicMember: keyPath]
        self.observeGlobalEnvironment()
    }
    
    public func discardValueSet() {
        injectedValue = nil
    }
    
    private func observeGlobalEnvironment() {
        observerCancellable = globalEnvironmentValues.publisher(for: keyPath)
            .weakAssign(to: \.resolvedValue, on: self)
    }
}
