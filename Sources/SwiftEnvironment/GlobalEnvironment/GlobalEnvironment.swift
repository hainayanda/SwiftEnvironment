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
    private var cancellables: Set<AnyCancellable> = []
    
    @State private var lastAssignmentId: UUID?
    @State private var injectedValue: Value?
    private lazy var resolvedValue: Value = globalEnvironmentValues[dynamicMember: keyPath]
    public var wrappedValue: Value {
        get { injectedValue ?? resolvedValue }
        set { injectedValue = newValue }
    }
    
    public init(_ keyPath: WritableKeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
        observeGlobalEnvironment()
    }
    
    public func discardValueSet() {
        injectedValue = nil
    }
    
    private func observeGlobalEnvironment() {
        globalEnvironmentValues.publisher(for: keyPath)
            .weakAssign(to: \.resolvedValue, on: self)
            .store(in: &cancellables)
        
        globalEnvironmentValues.assignedResolversSubject
            .map { $0.1.id }
            .weakAssign(to: \.lastAssignmentId, on: self)
            .store(in: &cancellables)
            
    }
}
