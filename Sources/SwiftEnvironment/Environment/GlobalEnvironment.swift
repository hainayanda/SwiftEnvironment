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

/// A property wrapper that provides access to global environment values.
/// 
/// `GlobalEnvironment` implements `DynamicProperty`, which means it can be used in SwiftUI views
/// and will automatically trigger view updates when the underlying value changes.
/// 
/// Example:
/// ```swift
/// struct MyView: View {
///     @GlobalEnvironment(\.myValue) var myValue
///     
///     var body: some View {
///         Text(myValue.description)
///     }
/// }
/// ```
@propertyWrapper
public final class GlobalEnvironment<Value>: DynamicProperty, PropertyWrapperDiscardable, @unchecked Sendable {
    
    private let keyPath: KeyPath<GlobalValues, Value>
    private var cancellables: Set<AnyCancellable> = []
    
    @State private var lastAssignmentId: UUID?
    @State private var injectedValueVersion: Int = 0

    private var injectedValue: Value?

    private lazy var resolvedValue: Value = GlobalValues()[keyPath: keyPath]

    /// The value of the property wrapper.
    ///
    /// If a value has been locally injected (e.g., in a test or preview), this returns the injected value.
    /// Otherwise, it returns the value resolved from the global environment.
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
            DispatchQueue.main.async { [weak self] in
                self?.injectedValueVersion &+= 1
            }
        }
    }
    
    /// Initializes the property wrapper with a key path to a global value.
    /// 
    /// - Parameter keyPath: The key path to the global value in `GlobalValues`.
    public init(_ keyPath: KeyPath<GlobalValues, Value>) {
        self.keyPath = keyPath
        observeGlobalEnvironment()
    }
    
    /// Discards any locally injected value, reverting to the global value.
    /// 
    /// This is useful in testing scenarios where you want to clear a test injection
    /// and return to the normal global value.
    public func discardValueSet() {
        atomicWrite {
            injectedValue = nil
        }
        DispatchQueue.main.async { [weak self] in
            self?.injectedValueVersion = 0
        }
    }
    
    private func observeGlobalEnvironment() {
        GlobalValues.publisher(for: keyPath)
            .weakAssign(to: \.resolvedValue, on: self)
            .store(in: &cancellables)
        
        GlobalValues.assignedResolversSubject
            .map { $0.1.id }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .weakAssign(to: \.lastAssignmentId, on: self)
            .store(in: &cancellables)
    }
    
    /// Reads a value atomically using the property wrapper's internal queue.
    /// 
    /// This ensures thread-safe access to the property wrapper's state.
    /// 
    /// - Parameter block: A closure that reads the value.
    /// - Returns: The result of the closure.
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
