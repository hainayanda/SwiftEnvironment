//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 21/4/24.
//

import Foundation
import SwiftSyntax

extension AttributeSyntax {
    var hasModifiers: Bool {
        guard let firstArgument = arguments?.as(LabeledExprListSyntax.self)?
            .first?.as(LabeledExprSyntax.self) else { return false }
        return firstArgument.trimmedDescription == ".publicStub"
        || firstArgument.trimmedDescription == ".internalStub"
    }
    
    var isPublicStub: Bool {
        guard let firstArgument = arguments?.as(LabeledExprListSyntax.self)?
            .first?.as(LabeledExprSyntax.self) else { return false }
        return firstArgument.trimmedDescription == ".publicStub"
    }
    
    var defaultValueArguments: [String: String] {
        get throws {
            let arguments = arguments?.as(LabeledExprListSyntax.self)?
                .filter { $0.label == nil }
                .compactMap { $0.as(LabeledExprSyntax.self) }
            guard var arguments else { return [:] }
            arguments = hasModifiers ? Array(arguments.suffix(from: 1)) : arguments
            return try arguments
                .map { try $0.extractDefaultValueArguments() }
                .mapToTypeDefaultValueArguments()
        }
    }
}

private extension LabeledExprSyntax {
    func extractDefaultValueArguments() throws -> FunctionCallExprSyntax {
        guard let expression = expression.as(FunctionCallExprSyntax.self),
              expression.calledExpression.trimmedDescription.match(#"^(DefaultType)?\.`?value`?$"#) else {
            throw StubGeneratorMacroError.unknownArguments(trimmedDescription)
        }
        return expression
    }
}

private extension Sequence where Element == FunctionCallExprSyntax {
    func mapToTypeDefaultValueArguments() throws -> [String: String] {
        try reduce(into: [:]) { partialResult, expression in
            let innerArgs = expression.arguments.map { $0 }
            guard innerArgs.count == 2,
                  innerArgs[0].label?.trimmedDescription == "for",
                  innerArgs[1].label == nil,
                  let memberAccess = innerArgs[0].expression.as(MemberAccessExprSyntax.self),
                  let type = memberAccess.base?.trimmedDescription else {
                throw StubGeneratorMacroError.unknownArguments(expression.trimmedDescription)
            }
            let defaultValue = innerArgs[1].trimmedDescription
            partialResult[type] = defaultValue
        }
    }
}