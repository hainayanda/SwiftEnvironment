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
    
    private let resolver: EnvironmentValuesResolving
    private let keyPath: KeyPath<EnvironmentValues, Value>
    private var observerCancellable: AnyCancellable?
    
    private var injectedValue: Value?
    private lazy var resolvedValue: Value = resolveAndObserveValue()
    public var wrappedValue: Value {
        get { injectedValue ?? resolvedValue }
        set { injectedValue = newValue }
    }
    
    public var projectedValue: PropertyWrapperDiscardableControl {
        PropertyWrapperDiscardableControl(propertyWrapper: self)
    }
    
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
        self.resolver = EnvironmentValuesResolver.global
    }
    
    public func discardValueSet() {
        injectedValue = nil
    }
    
    private func resolveAndObserveValue() -> Value {
        observerCancellable = resolver.environmentValuePublisher(for: keyPath)
            .weakAssign(to: \.resolvedValue, on: self)
        return resolver.resolve(keyPath)
    }
}

extension Publisher where Failure == Never {
    func weakAssign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on object: Root) -> AnyCancellable {
        sink { [weak object] output in
            object?[keyPath: keyPath] = output
        }
    }
}
