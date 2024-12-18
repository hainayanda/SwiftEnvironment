//
//  File.swift
//
//
//  Created by Nayanda Haberty on 16/3/24.
//

import Foundation
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntax

struct StubFromProtocolGeneratorMacro: PeerMacro {
    @inlinable public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let protocolSyntax = declaration.as(ProtocolDeclSyntax.self) else {
            return []
        }
        let isObjectProtocol: Bool = protocolSyntax.isObjectProtocol
        let defaultValues = try node.defaultValueArguments
            .reduce(into: baseDefaultValues) { partialResult, pair in
                partialResult[pair.key] = pair.value
            }
        let instanceType = try node.typeArgument(for: protocolSyntax.name.text, isObjectProtocol: isObjectProtocol)
        let variables = try protocolSyntax.memberBlock.members
            .variables.patternBindings
            .toVariableDeclaration(use: defaultValues)
        let methods = try protocolSyntax.memberBlock.members
            .methods
            .toMethodProtocolDeclaration(use: defaultValues)
        let result = StubDeclaration(
            instanceType: instanceType,
            name: protocolSyntax.stubName,
            variables: variables,
            methods: methods
        )
        return [ "\(raw: result.description)" ]
    }
}

// MARK: Private extensions

private extension ProtocolDeclSyntax {
    var isObjectProtocol: Bool {
        inheritanceClause?.inheritedTypes.contains {
            $0.trimmedDescription == "AnyObject" 
            || $0.trimmedDescription == "class"
            || $0.trimmedDescription == "NSObject"
        } ?? false
    }
    
    var stubName: String {
        "\(name.text)Stub"
    }
}

private extension AttributeSyntax {
    
    func typeArgument(for protocolName: String, isObjectProtocol: Bool) throws -> StubDeclaration.InstanceType {
        let baseArgument = arguments?.as(LabeledExprListSyntax.self)?
            .first { $0.label?.trimmedDescription == "type" }?
            .as(LabeledExprSyntax.self)
        guard let baseArgument else {
            return isObjectProtocol ?
                .class(protocol: protocolName, superClass: nil):
                .struct(protocol: protocolName)
        }
        let simpleArgument = baseArgument.expression.as(MemberAccessExprSyntax.self)
        if let simpleArgument {
            return try simpleTypeArgument(
                for: protocolName, argument: simpleArgument,
                isObjectProtocol: isObjectProtocol
            )
        }
        let functionArgument = baseArgument.expression.as(FunctionCallExprSyntax.self)
        if let functionArgument {
            return try argsTypeArgument(for: protocolName, argument: functionArgument)
        }
        return isObjectProtocol ?
            .class(protocol: protocolName, superClass: nil):
            .struct(protocol: protocolName)
    }
    
    func simpleTypeArgument(
        for protocolName: String,
        argument: MemberAccessExprSyntax,
        isObjectProtocol: Bool) throws -> StubDeclaration.InstanceType {
            if argument.trimmedDescription.match(#"^(StubType)?\.`?struct`?$"#) {
                guard !isObjectProtocol else {
                    throw StubGeneratorMacroError.cannotUseStructForObjectProtocol
                }
                return .struct(protocol: protocolName)
            } else if argument.trimmedDescription.match(#"^(StubType)?\.`?class`?$"#) {
                return .class(protocol: protocolName, superClass: nil, final: true)
            } else if argument.trimmedDescription.match(#"^(StubType)?\.openClass$"#) {
                return .class(protocol: protocolName, superClass: nil, final: false)
            } else {
                throw StubGeneratorMacroError.cannotDetermineDefaultValue(argument.trimmedDescription)
            }
        }
    
    func argsTypeArgument(for protocolName: String, argument: FunctionCallExprSyntax) throws -> StubDeclaration.InstanceType {
        let isSubclass: Bool = argument.calledExpression.trimmedDescription.match(#"^(StubType)?\.subclass$"#)
        let isOpenSubclass: Bool = argument.calledExpression.trimmedDescription.match(#"^(StubType)?\.openSubclass$"#)
        guard isSubclass || isOpenSubclass,
              let argumentExpression = argument.arguments.first?.expression,
              argumentExpression.trimmedDescription.match(#"^\S+\.self$"#),
              let memberAccess = argumentExpression.as(MemberAccessExprSyntax.self),
              let superClass = memberAccess.base?.trimmedDescription else {
            throw StubGeneratorMacroError.cannotDetermineDefaultValue(argument.trimmedDescription)
        }
        return .class(protocol: protocolName, superClass: superClass, final: isSubclass)
    }
}

private extension Sequence where Element == FunctionDeclSyntax {
    func toMethodProtocolDeclaration(use mappedValue: [String: String]) throws -> [MethodProtocolDeclaration] {
        try map { function in
            let returnClause = function.signature.returnClause?.as(ReturnClauseSyntax.self)
            let defaultReturnClause = try returnClause?.defaultReturnClause(use: mappedValue)
            return MethodProtocolDeclaration(
                wholeDeclaration: function.trimmedDescription,
                returnClause: defaultReturnClause ?? ""
            )
        }
    }
}

private extension Sequence where Element == PatternBindingSyntax {
    func toVariableDeclaration(use mappedValue: [String: String]) throws -> [VariableProtocolDeclaration] {
        try map { binding in
            guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.trimmedDescription,
                let type = binding.typeAnnotation?.type,
                let accessors = binding.accessorBlock?.accessors.as(AccessorDeclListSyntax.self),
                accessors.contains(where: { $0.accessorSpecifier.text == "get" }) else {
              throw StubGeneratorMacroError.failedToExtractVariables
            }
            let mutable = accessors.contains { $0.accessorSpecifier.text == "set" }
            return try VariableProtocolDeclaration(
                name: name, declaration: mutable ? .var: .let,
                typeAnnotiation: type.trimmedDescription,
                defaultValue: type.defaultValue(use: mappedValue)
            )
        }
    }
}
