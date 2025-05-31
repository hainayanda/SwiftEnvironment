//
//  SwiftEnvironmentMacroError.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 31/05/25.
//

import Foundation

public enum SwiftEnvironmentMacroError: Error, CustomStringConvertible {
    case mustBeUsedInsideGlobalValues
    case expectedInitializerValue
    
    public var description: String {
        switch self {
        case .mustBeUsedInsideGlobalValues:
            return "The @GlobalEntry macro must be used inside a global values extensions."
        case .expectedInitializerValue:
            return "Expected an initializer value for the property annotated with @GlobalEntry."
        }
    }
}
