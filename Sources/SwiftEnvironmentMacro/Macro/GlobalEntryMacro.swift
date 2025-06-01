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
        guard let typeAnnotation = binding.typeAnnotation else {
            throw SwiftEnvironmentMacroError.expectedTypeAnnotation
        }
        return [
            DeclSyntax(
                """
                nonisolated(unsafe) private static let ___\(raw: varName): \(raw: typeAnnotation.type.trimmedDescription) = \(initializer)
                """
            )
        ]
    }
}
