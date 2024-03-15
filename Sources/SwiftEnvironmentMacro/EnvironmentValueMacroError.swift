//
//  EnvironmentValueMacroError.swift
//  
//
//  Created by Nayanda Haberty on 15/3/24.
//

import Foundation

public enum EnvironmentValueMacroError: CustomStringConvertible, Error {
    case noArgumentPassed
    case noKeyPathProvided
    case wrongArgumentValue
    case attachedToInvalidType
    case noEnvironmentKeyProvided
    case duplicatedKeyPaths
    case duplicatedEnvironmentKeys
    case undeterminedEnvironmentValueType
    case missingEnvironmentKeyValuePair
    
    public var description: String {
        switch self {
        case .noArgumentPassed:
            return "@EnvironmentValue can only be applied with arguments passed"
        case .noKeyPathProvided:
            return "@EnvironmentValue can only be applied with provided name of KeyPath"
        case .wrongArgumentValue:
            return "@EnvironmentValue argument value is wrong"
        case .attachedToInvalidType:
            return "@EnvironmentValue can only be attached to extension of EnvironmentValues"
        case .noEnvironmentKeyProvided:
            return "@EnvironmentValue failed to extract EnvironmentKey"
        case .duplicatedKeyPaths:
            return "@EnvironmentValue provided KeyPaths is duplicated"
        case .undeterminedEnvironmentValueType:
            return "@EnvironmentValue cannot determine EnvironmentValue type"
        case .duplicatedEnvironmentKeys:
            return "@EnvironmentValue provided EnvironmentKeys is duplicated"
        case .missingEnvironmentKeyValuePair:
            return "@EnvironmentValue provided KeyPaths number is not the same as provided EnvironmentKeys"
        }
    }
}
