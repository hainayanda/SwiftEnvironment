//
//  UIEnvironment.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 5/11/24.
//

#if canImport(UIKit)
import UIKit

@propertyWrapper
public final class UIEnvironment<Value>: PropertyWrapperDiscardable {
    
    public static subscript<EnclosingType: UIResponder>(
        _enclosingInstance instance: EnclosingType,
        wrapped wrappedKeyPath: KeyPath<EnclosingType, Value>,
        storage storageKeyPath: KeyPath<EnclosingType, UIEnvironment>
    ) -> Value {
        get {
            let wrapper = instance[keyPath: storageKeyPath]
            return wrapper._wrappedValue ?? instance.resolve(wrapper.keyPath)
        }
        set {
            instance[keyPath: storageKeyPath]._wrappedValue = newValue
        }
    }
    
    private let keyPath: KeyPath<EnvironmentValues, Value>
    
    private var _wrappedValue: Value?
    
    @available(*, unavailable, message: "Enclosing type must be instance of UIResponder")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
    
    public var projectedValue: PropertyWrapperDiscardableControl {
        PropertyWrapperDiscardableControl(propertyWrapper: self)
    }
    
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
    }
    
    public func discardValueSet() {
        _wrappedValue = nil
    }
}
#endif
