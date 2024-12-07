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
    
    @inlinable var singletonDeclaration: String {
        let modifier = isPublicStub ? "public " : ""
        let singletonClause = "\(modifier)static var stub: \(name) { \(name)("
        let arguments = argumentPairs.compactMap { $0.asArguments }.joined(separator: ", ")
        return "\(singletonClause)\(arguments)) }"
    }
    
    @inlinable var initDeclaration: String? {
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
    
    @inlinable init(name: String, type: String, value: String = "") {
        self.name = name
        self.type = type
        self.value = value
    }
    
    @inlinable var asArguments: String {
        "\(name): \(value)"
    }
    
    @inlinable var asInitDeclaration: String {
        "\(name): \(type)"
    }
    
    @inlinable var asInitBodyInitializer: String {
        "self.\(name) = \(name)"
    }
}
