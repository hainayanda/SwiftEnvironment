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
    
    init(propertyWrapper: PropertyWrapperDiscardable) {
        self.propertyWrapper = propertyWrapper
    }
    
    func discardValueSet() {
        propertyWrapper.discardValueSet()
    }
}
