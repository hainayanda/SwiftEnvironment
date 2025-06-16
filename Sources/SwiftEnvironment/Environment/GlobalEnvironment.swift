//
//  GlobalEnvironment.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 14/3/24.
//

import Foundation
import Combine
import SwiftUI

private let accessQueue = DispatchQueue(label: "GlobalEnvironment.accessQueue", attributes: .concurrent)

@propertyWrapper
public final class GlobalEnvironment<Value>: DynamicProperty, PropertyWrapperDiscardable, @unchecked Sendable {
    
    private let keyPath: KeyPath<GlobalValues, Value>
    private var cancellables: Set<AnyCancellable> = []
    
    
    @State private var lastAssignmentId: UUID?
    @State private var injectedValue: Value?
    private lazy var resolvedValue: Value = GlobalValues()[keyPath: keyPath]
    public var wrappedValue: Value {
        get {
            atomicRead {
                injectedValue ?? resolvedValue
            }
        }
        set {
            atomicWrite {
                injectedValue = newValue
            }
        }
    }
    
    public init(_ keyPath: KeyPath<GlobalValues, Value>) {
        self.keyPath = keyPath
        observeGlobalEnvironment()
    }
    
    public func discardValueSet() {
        atomicWrite {
            injectedValue = nil
        }
    }
    
    private func observeGlobalEnvironment() {
        GlobalValues.publisher(for: keyPath)
            .weakAssign(to: \.resolvedValue, on: self)
            .store(in: &cancellables)
        
        GlobalValues.assignedResolversSubject
            .map { $0.1.id }
            .removeDuplicates()
            .weakAssign(to: \.lastAssignmentId, on: self)
            .store(in: &cancellables)
    }
    
    public func atomicRead<Result>(_ block: () throws -> Result) rethrows -> Result {
        try accessQueue.safeSync {
            try block()
        }
    }
    
    private func atomicWrite<Result>(_ block: () throws -> Result) rethrows -> Result {
        try accessQueue.safeSync(flags: .barrier) {
            try block()
        }
    }
}
