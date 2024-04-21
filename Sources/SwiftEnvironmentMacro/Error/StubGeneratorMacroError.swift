//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 17/3/24.
//

import Foundation

public enum StubGeneratorMacroError: CustomStringConvertible, Error {
    case failedToExtractVariables
    case cannotDetermineDefaultValue(String)
    case unknownArguments(String)
    case cannotUseStructForObjectProtocol
    case cannotDetermineType(String)
    
    public var description: String {
        switch self {
        case .failedToExtractVariables:
            return "@Stubbed failed to extract one of variables"
        case .cannotDetermineDefaultValue(let type):
            return "@Stubbed failed to determine default value for \(type)"
        case .unknownArguments(let arg):
            return "@Stubbed got unknown argument of \(arg)"
        case .cannotUseStructForObjectProtocol:
            return "@Stubbed should use class as type arguments because the protocol is marked as AnyObject"
        case .cannotDetermineType(let arg):
            return "@Stubbed failed to determined type of \(arg)"
        }
    }
}
