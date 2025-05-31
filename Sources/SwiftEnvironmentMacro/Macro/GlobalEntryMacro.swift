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

public struct GlobalEntryMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {

//        guard let parentExtension = declaration.parent?.as(ExtensionDeclSyntax.self),
//              let extendedType = parentExtension.extendedType.as(IdentifierTypeSyntax.self),
//              extendedType.name.text == "GlobalValues"
//        else {
//            throw SwiftEnvironmentMacroError.mustBeUsedInsideGlobalValues
//        }

        guard let varDecl = declaration.as(VariableDeclSyntax.self),
              let binding = varDecl.bindings.first,
              let varName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
              let initializer = binding.initializer?.value
        else {
            throw SwiftEnvironmentMacroError.expectedInitializerValue
        }

        return [
            AccessorDeclSyntax(
                """
                get {
                    self[\\.\(raw: varName)] ?? \(initializer)
                }
                """
            )
        ]
    }
}
