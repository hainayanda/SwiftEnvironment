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
    
    @inlinable var description: String {
        let declaration = "\(instanceType.declarationString(for: name)) {\n"
        let withStaticStub = "\(declaration)    static var stub: \(instanceType.protocolName) { \(name)() }\n"
        let withVariables = variables.reduce(withStaticStub) { partialResult, variable in
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
        case `class`(`protocol`: String, superClass: String? = nil, final: Bool = true)
        case `struct`(`protocol`: String)
        
        @inlinable func declarationString(for name: String) -> String {
            switch self {
            case .class(let protocolName, let superClass, let final):
                return "\(final ? "final ": "")class \(name): \(superClassClause(for: superClass))\(protocolName)"
            case .struct(let protocolName):
                return "struct \(name): \(protocolName)"
            }
        }
        
        @inlinable func superClassClause(for superClass: String?) -> String {
            guard let superClass else { return "" }
            return "\(superClass), "
        }
        
        @inlinable var protocolName: String {
            switch self {
            case .class(let protocolName, _, _), .struct(let protocolName):
                return protocolName
            }
        }
    }
}
