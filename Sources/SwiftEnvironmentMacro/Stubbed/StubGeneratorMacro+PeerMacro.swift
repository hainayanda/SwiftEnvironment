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

extension StubGeneratorMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let protocolSyntax = declaration.as(ProtocolDeclSyntax.self) else {
            return []
        }
        let isObjectProtocol: Bool = protocolSyntax.inheritanceClause?
            .inheritedTypes.contains { $0.trimmedDescription == "AnyObject" } ?? false
        let defaultValues = try node.defaultValueArguments
            .reduce(into: baseDefaultValues) { partialResult, pair in
                partialResult[pair.key] = pair.value
            }
        let result = try protocolSyntax.defaultInstance(
            node.typeArgument(
                for: protocolSyntax.name.text,
                isObjectProtocol: isObjectProtocol
            ),
            givenName: node.nameArgument,
            with: DefaultValueGenerator(defaultValues: defaultValues)
        )
        return [ "\(raw: result.description)" ]
    }
}

// MARK: Private extensions

private extension AttributeSyntax {
    var nameArgument: String? {
        let argument = arguments?.as(LabeledExprListSyntax.self)?
            .first { $0.label?.trimmedDescription == "name" }
        guard let argument else { return nil }
        return argument.expression.as(StringLiteralExprSyntax.self)?
            .segments.first?.trimmedDescription
    }
    
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

private extension VariableDeclSyntax {
    func mapToVariableProtocolDeclaration(with defaultValues: DefaultValueGenerator) throws -> VariableProtocolDeclaration {
        guard let pattern = bindings.first?.as(PatternBindingSyntax.self),
              let name = pattern.pattern.as(IdentifierPatternSyntax.self)?.trimmedDescription,
              let type = pattern.typeAnnotation?.type.trimmedDescription,
              let accessors = pattern.accessorBlock?.accessors.as(AccessorDeclListSyntax.self),
              accessors.contains(where: { $0.accessorSpecifier.text == "get" }) else {
            throw StubGeneratorMacroError.failedToExtractVariables
        }
        let mutable = accessors.contains { $0.accessorSpecifier.text == "set" }
        return try VariableProtocolDeclaration(
            name: name, declaration: mutable ? .var: .let, 
            typeAnnotiation: type,
            defaultValue: defaultValues.defaultValue(for: type)
        )
    }
}

private extension FunctionDeclSyntax {
    
    func mapToMethodProtocolDeclaration(with defaultValues: DefaultValueGenerator) throws -> MethodProtocolDeclaration {
        let returnClause = signature.returnClause?.as(ReturnClauseSyntax.self)
        let returnType = returnClause?.type.trimmedDescription ?? "Void"
        return try MethodProtocolDeclaration(
            wholeDeclaration: trimmedDescription,
            returnValue: .init(returnType, defaultValue: defaultValues)
        )
    }
}

private extension ProtocolDeclSyntax {
    func defaultInstance(_ instanceType: StubDeclaration.InstanceType, givenName: String?, with defaultValues: DefaultValueGenerator) throws -> StubDeclaration {
        try StubDeclaration(
            instanceType: instanceType, name: "\(givenName ?? name.text)Stub",
            variables: variables(with: defaultValues),
            methods: methods(with: defaultValues)
        )
    }
    
    func variables(with defaultValues: DefaultValueGenerator) throws -> [VariableProtocolDeclaration] {
        try memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .map { try $0.mapToVariableProtocolDeclaration(with: defaultValues) }
    }
    
    func methods(with defaultValues: DefaultValueGenerator) throws -> [MethodProtocolDeclaration] {
        try memberBlock.members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
            .map { try $0.mapToMethodProtocolDeclaration(with: defaultValues) }
    }
}
