//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 1/4/24.
//

import Foundation

struct StubInitializer {
    let isPublicStub: Bool
    let name: String
    let generateInit: Bool
    let argumentPairs: [InitArgumentPairs]
    
    var singletonDeclaration: String {
        let modifier = isPublicStub ? "public " : ""
        let singletonClause = "\(modifier)static var stub: \(name) { \(name)("
        let arguments = argumentPairs.compactMap { $0.asArguments }.joined(separator: ", ")
        return "\(singletonClause)\(arguments)) }"
    }
    
    var initDeclaration: String? {
        guard generateInit else {
            return nil
        }
        let initArguments = argumentPairs.compactMap { $0.asInitDeclaration }.joined(separator: ", ")
        let body = argumentPairs.compactMap { $0.asInitBodyInitializer }.joined(separator: "\n    ")
        return """
        init(\(initArguments)) {
            \(body)
        }
        """
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
