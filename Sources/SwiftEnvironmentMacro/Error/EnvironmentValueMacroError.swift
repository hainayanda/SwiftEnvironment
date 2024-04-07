//
//  EnvironmentValueMacroError.swift
//  
//
//  Created by Nayanda Haberty on 15/3/24.
//

import Foundation

public enum EnvironmentValueMacroError: CustomStringConvertible, Error {
    case attachedToInvalidType
    
    public var description: String {
        switch self {
        case .attachedToInvalidType:
            return "@EnvironmentValue can only be attached to extension of EnvironmentValues"
        }
    }
}
