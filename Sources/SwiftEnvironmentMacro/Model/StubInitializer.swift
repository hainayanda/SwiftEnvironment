//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 1/4/24.
//

import Foundation

struct StubInitializer: CustomStringConvertible {
    let name: String
    let generateInit: Bool
    let argumentPairs: [InitArgumentPairs]
    
    var description: String {
        let singletonClause = "static var stub: \(name) = \(name)("
        let arguments = argumentPairs.compactMap { $0.asArguments }.joined(separator: ", ")
        if generateInit {
            let initArguments = argumentPairs.compactMap { $0.asInitDeclaration }.joined(separator: ", ")
            let body = argumentPairs.compactMap { $0.asInitBodyInitializer }.joined(separator: "\n    ")
            return """
            \(singletonClause)\(arguments))
            init(\(initArguments)) {
                \(body)
            }
            """
        }
        return "    \(singletonClause)\(arguments))"
    }
}

struct InitArgumentPairs {
    let name: String
    let type: String
    let value: String
    
    init(name: String, type: String, value: String = "") {
        self.name = name
        self.type = type
        self.value = value
    }
    
    var asArguments: String {
        "\(name): \(value)"
    }
    
    var asInitDeclaration: String {
        "\(name): \(type)"
    }
    
    var asInitBodyInitializer: String {
        "self.\(name) = \(name)"
    }
}