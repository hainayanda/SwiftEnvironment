//
//  GlobalEntryMacro.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 31/05/25.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct GlobalEntryMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let varName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        else {
            throw SwiftEnvironmentMacroError.expectedInitializerValue
        }
        return [
            AccessorDeclSyntax(
                """
                get {
                    self[\\.\(raw: varName)] ?? GlobalValues.___\(raw: varName)
                }
                """
            )
        ]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let varName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
              let initializer = binding.initializer?.value
        else {
            throw SwiftEnvironmentMacroError.expectedInitializerValue
        }
        let modifier = isIsolated(node) ? "" : "nonisolated(unsafe) "
        
        guard let typeAnnotation = binding.typeAnnotation else {
            throw SwiftEnvironmentMacroError.expectedTypeAnnotation
        }
        return [
            DeclSyntax(
                """
                \(raw: modifier)private static let ___\(raw: varName): \(raw: typeAnnotation.type.trimmedDescription) = \(initializer)
                """
            )
        ]
    }
    
    private static func isIsolated(_ node: AttributeSyntax) -> Bool {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              let firstArgument = arguments.first,
              let expression = firstArgument.expression.as(MemberAccessExprSyntax.self) else {
            return false
        }
        let description = expression.trimmedDescription
        return description == ".isolated" || description == "StaticModifier.isolated"
    }
}
