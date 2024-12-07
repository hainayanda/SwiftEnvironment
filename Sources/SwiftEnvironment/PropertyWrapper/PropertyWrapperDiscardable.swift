//
//  PropertyWrapperDiscardable.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 6/11/24.
//


public protocol PropertyWrapperDiscardable {
    func discardValueSet()
    var projectedValue: PropertyWrapperDiscardableControl { get }
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
