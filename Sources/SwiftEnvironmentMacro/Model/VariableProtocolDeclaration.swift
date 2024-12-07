//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 17/3/24.
//

import Foundation

struct VariableProtocolDeclaration: CustomStringConvertible {
    let name: String
    let declaration: Declaration
    let typeAnnotiation: String
    let defaultValue: String
    
    @inlinable var description: String {
        "\(declaration.rawValue) \(name): \(typeAnnotiation) = \(defaultValue)"
    }
}

extension VariableProtocolDeclaration {
    
    enum Declaration: String {
        case `let`
        case `var`
    }
}
