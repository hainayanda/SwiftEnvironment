//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 17/3/24.
//

import Foundation
import SwiftSyntax

let baseDefaultValues: [String: String] = [
    "Int": "0", "Int8": "0", "Int16": "0", "Int32": "0", "Int64": "0",
    "UInt": "0", "UInt8": "0", "UInt16": "0", "UInt32": "0", "UInt64": "0",
    "Float": "0", "Float16": "0", "Float32": "0", "Float64": "0.0", "Double": "0.0",
    "Bool": "false", "Character": "Character(\"\")", "String": "\"\"", "Data": "Data()",
    "Date": "Date()", "UUID": "UUID()",
    "CGFloat": "0", "CGSize": ".zero", "CGPoint": ".zero", "CGRect": ".zero",
    "NSNumber": "0", "NSString": "\"\"", "NSNull": "NSNull()", "NSObject": "NSObject()",
    "NSData": "NSData()", "NSDate": "NSDate()", "NSSet": "NSSet()", "NSArray": "NSArray()",
    "NSSize": ".zero", "NSPoint": ".zero", "NSRect": ".zero",
    "AnyView": "AnyView(EmptyView())"
]

extension AttributeSyntax {
    var defaultValueArguments: [String: String] {
        get throws {
            let arguments = arguments?.as(LabeledExprListSyntax.self)?
                .filter { $0.label == nil }
                .compactMap { $0.as(LabeledExprSyntax.self) }
            guard let arguments else { return [:] }
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
