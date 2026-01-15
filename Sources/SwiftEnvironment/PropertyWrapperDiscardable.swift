//
//  PropertyWrapperDiscardable.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 10/03/25.
//

import Foundation

/// A protocol for property wrappers that support discarding locally set values.
/// This allows property wrappers to clear any locally injected values and revert to defaults.
public protocol PropertyWrapperDiscardable {
    /// Discards any locally set value, reverting to the default or resolved value.
    func discardValueSet()
    
    /// The projected value of the property wrapper, which provides control over the wrapper's behavior.
    /// 
    /// For `PropertyWrapperDiscardable`, this provides access to the `discardValueSet()` method.
    var projectedValue: PropertyWrapperDiscardableControl { get }
}

extension PropertyWrapperDiscardable {
    public var projectedValue: PropertyWrapperDiscardableControl {
        PropertyWrapperDiscardableControl(propertyWrapper: self)
    }
}

/// A control structure for property wrappers that implement `PropertyWrapperDiscardable`.
/// This provides an interface to control the property wrapper's behavior, particularly for discarding values.
public struct PropertyWrapperDiscardableControl {
    private let propertyWrapper: PropertyWrapperDiscardable
    
    @usableFromInline init(propertyWrapper: PropertyWrapperDiscardable) {
        self.propertyWrapper = propertyWrapper
    }
    
    /// Discards any locally set value in the property wrapper, reverting to the default or resolved value.
    public func discardValueSet() {
        propertyWrapper.discardValueSet()
    }
}
