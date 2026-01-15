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

/// A macro that generates a computed property with a default value for use in `GlobalValues` extensions.
/// 
/// The `@GlobalEntry` macro creates:
/// 1. A computed property that returns either the injected value or the default value
/// 2. A private static constant holding the default value
/// 3. A private nested struct that wraps the default value
/// 
/// Example:
/// ```swift
/// extension GlobalValues {
///     @GlobalEntry var myService: MyService = MyService()
/// }
/// ```
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
                    GlobalValues.atomicRead {
                        self[\\.\(raw: varName)] ?? GlobalValues.___\(raw: varName).value
                    }
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
        let typeString = typeAnnotation.type.trimmedDescription
        let isolatedWrapper: String = "___ValueWrapper_\(varName)"
        return [
            DeclSyntax(
                """
                private static let ___\(raw: varName): \(raw: isolatedWrapper) = \(raw: isolatedWrapper)()
                """
            ),
            DeclSyntax(
                """
                private struct \(raw: isolatedWrapper): @unchecked Sendable {
                    let value: \(raw: typeString) = \(initializer)
                }
                """
            )
        ]
    }
}
