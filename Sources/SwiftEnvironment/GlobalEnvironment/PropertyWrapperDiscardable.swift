//
//  PropertyWrapperDiscardable.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 10/03/25.
//

import Foundation

public protocol PropertyWrapperDiscardable {
    func discardValueSet()
    var projectedValue: PropertyWrapperDiscardableControl { get }
}

extension PropertyWrapperDiscardable {
    public var projectedValue: PropertyWrapperDiscardableControl {
        PropertyWrapperDiscardableControl(propertyWrapper: self)
    }
}

public struct PropertyWrapperDiscardableControl {
    private let propertyWrapper: PropertyWrapperDiscardable
    
    @usableFromInline init(propertyWrapper: PropertyWrapperDiscardable) {
        self.propertyWrapper = propertyWrapper
    }
    
    @usableFromInline func discardValueSet() {
        propertyWrapper.discardValueSet()
    }
}
