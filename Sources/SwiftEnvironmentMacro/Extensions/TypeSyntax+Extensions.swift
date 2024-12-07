//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 21/4/24.
//

import Foundation
import SwiftSyntax

extension TypeSyntax {
    @inlinable func defaultValue(use mappedValue: [String: String]) throws -> String {
        if let value = mappedValue[trimmedDescription] {
            return value
        } else if description.isVoidPattern {
            return "Void()"
        } else if self.as(OptionalTypeSyntax.self) != nil || trimmedDescription.isOptionalPattern {
            return "nil"
        } else if self.as(ArrayTypeSyntax.self) != nil || trimmedDescription.isArrayPattern {
            return "[]"
        } else if self.as(DictionaryTypeSyntax.self) != nil || trimmedDescription.isDictionaryPattern {
            return "[:]"
        } else if let function = self.as(FunctionTypeSyntax.self) {
            let argumentCount = function.parameters.as(TupleTypeElementListSyntax.self)?.count ?? 0
            let arguments = (0..<argumentCount).reduce("") { partialResult, _ in
                if partialResult.isEmpty { return "_" }
                return "\(partialResult), _"
            }
            let argumentsClause = arguments.isEmpty ? "" : "\(arguments) in"
            let returnClause = try function.returnClause.defaultReturnClause(use: mappedValue)
            return "{ \(argumentsClause) \(returnClause) }"
        } else if let tuple = self.as(TupleTypeSyntax.self) {
            let partial = try tuple.elements.map { element in
                try element.type.defaultValue(use: mappedValue)
            }
            .reduce("") { partialResult, value in
                if partialResult.isEmpty { return value }
                return "\(partialResult), \(value)"
            }
            return "(\(partial))"
        } else {
            return "\(trimmedDescription)Stub.stub"
        }
    }
}
