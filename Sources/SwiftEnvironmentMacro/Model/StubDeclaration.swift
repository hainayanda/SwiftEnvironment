//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 17/3/24.
//

import Foundation

struct StubDeclaration: CustomStringConvertible {
    let instanceType: InstanceType
    let name: String
    let variables: [VariableProtocolDeclaration]
    let methods: [MethodProtocolDeclaration]
    
    var description: String {
        let declaration = "\(instanceType.declarationString(for: name)) {\n"
        let withVariables = variables.reduce(declaration) { partialResult, variable in
            "\(partialResult)    \(variable.description)\n"
        }
        let withInit = "\(withVariables)    init() { }\n"
        let withMethods = methods.reduce(withInit) { partialResult, method in
            "\(partialResult)    \(method.description)\n"
        }
        return "\(withMethods)}"
    }
}

extension StubDeclaration {
    
    enum InstanceType {
        case `class`(`protocol`: String, superClass: String? = nil)
        case `struct`(`protocol`: String)
        
        func declarationString(for name: String) -> String {
            switch self {
            case .class(let protocolName, let superClass):
                return "final class \(name): \(superClassClause(for: superClass))\(protocolName)"
            case .struct(let protocolName):
                return "struct \(name): \(protocolName)"
            }
        }
        
        func superClassClause(for superClass: String?) -> String {
            guard let superClass else { return "" }
            return "\(superClass), "
        }
    }
}
