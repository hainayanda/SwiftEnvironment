//
//  SwiftEnvironmentMacroError.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 31/05/25.
//

import Foundation

/// Errors that can occur during macro expansion.
///
/// These errors are thrown when the `@GlobalEntry` macro is used incorrectly.
public enum SwiftEnvironmentMacroError: Error, CustomStringConvertible {
    /// The macro must be used inside a `GlobalValues` extension.
    case mustBeUsedInsideGlobalValues
    
    /// Expected an initializer value for the property.
    case expectedInitializerValue
    
    /// Expected a type annotation for the property.
    case expectedTypeAnnotation
    
    /// A human-readable description of the error.
    public var description: String {
        switch self {
        case .mustBeUsedInsideGlobalValues:
            return "The @GlobalEntry macro must be used inside a global values extensions."
        case .expectedInitializerValue:
            return "Expected an initializer value for the property annotated with @GlobalEntry."
        case .expectedTypeAnnotation:
            return "Expected a type annotation for the property annotated with @GlobalEntry."
        }
    }
}
