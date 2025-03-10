//
//  GlobalEnvironmentSource.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 10/03/25.
//

import SwiftUI
import Combine

@propertyWrapper
public final class GlobalEnvironmentSource: DynamicProperty {
    
    @State private var lastAssignmentId: UUID?
    public var wrappedValue: GlobalEnvironmentValues {
        didSet {
            observe()
        }
    }
    
    private var lastAssignmentCancellable: AnyCancellable? {
        willSet {
            lastAssignmentCancellable?.cancel()
        }
    }
    
    public init() {
        wrappedValue = EnvironmentValues.global
        observe()
    }
    
    func observe() {
        lastAssignmentCancellable = wrappedValue.assignedResolversSubject
            .map { $0.1.id }
            .weakAssign(to: \.lastAssignmentId, on: self)
    }
}
