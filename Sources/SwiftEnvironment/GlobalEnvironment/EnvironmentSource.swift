//
//  EnvironmentSource.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 10/03/25.
//

import SwiftUI
import Combine

@propertyWrapper
public final class EnvironmentSource: DynamicProperty {
    
    @State private var lastAssignmentId: UUID?
    public var wrappedValue: SwiftEnvironmentValues {
        didSet {
            observe()
        }
    }
    
    private var lastAssignmentCancellable: AnyCancellable? {
        willSet {
            lastAssignmentCancellable?.cancel()
        }
    }
    
    public init(_ source: Source) {
        switch source {
        case .global: wrappedValue = EnvironmentValues.global
        case .local: wrappedValue = SwiftEnvironmentValues()
        case .custom(let values): wrappedValue = values
        }
        observe()
    }
    
    func observe() {
        lastAssignmentCancellable = wrappedValue.assignedResolversSubject
            .map { $0.1.id }
            .weakAssign(to: \.lastAssignmentId, on: self)
    }
}

public extension EnvironmentSource {
    enum Source {
        case global
        case local
        case custom(SwiftEnvironmentValues)
    }
}
