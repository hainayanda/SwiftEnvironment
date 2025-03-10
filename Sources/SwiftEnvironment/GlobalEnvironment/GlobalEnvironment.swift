//
//  GlobalEnvironment.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 14/3/24.
//

import Foundation
import Combine

@propertyWrapper
public final class GlobalEnvironment<Value>: PropertyWrapperDiscardable {
    
    private let globalEnvironmentValues = EnvironmentValues.global
    private let keyPath: WritableKeyPath<EnvironmentValues, Value>
    private var observerCancellable: AnyCancellable?
    
    private var injectedValue: Value?
    private lazy var resolvedValue: Value = resolveAndObserveValue()
    public var wrappedValue: Value {
        get { injectedValue ?? resolvedValue }
        set { injectedValue = newValue }
    }
    
    public init(_ keyPath: WritableKeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
    }
    
    public func discardValueSet() {
        injectedValue = nil
    }
    
    private func resolveAndObserveValue() -> Value {
        observerCancellable = globalEnvironmentValues.publisher(for: keyPath)
            .weakAssign(to: \.resolvedValue, on: self)
        return globalEnvironmentValues[dynamicMember: keyPath]
    }
}
