//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 17/3/24.
//

import Foundation

struct MethodProtocolDeclaration: CustomStringConvertible {
    let wholeDeclaration: String
    let returnValue: ReturnValue
    
    var description: String {
        "\(wholeDeclaration) { \(returnValue.description) }"
    }
}

extension MethodProtocolDeclaration {
    
    enum ReturnValue: CustomStringConvertible {
        case void
        case `default`(String)
        
        init(_ type: String, defaultValue: DefaultValueGenerator) throws {
            guard type != "Void" else {
                self = .void
                return
            }
            self = try .default(defaultValue.defaultValue(for: type))
        }
        
        var description: String {
            switch self {
            case .void:
                return "return"
            case .default(let value):
                return "return \(value)"
            }
        }
    }
}
