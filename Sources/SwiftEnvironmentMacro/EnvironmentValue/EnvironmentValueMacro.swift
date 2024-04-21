//
//  EnvironmentValueMacro.swift
//
//
//  Created by Nayanda Haberty on 15/3/24.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

public struct EnvironmentValueMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let extensionDeclaration = declaration.as(ExtensionDeclSyntax.self),
              extensionDeclaration.extendedType.as(IdentifierTypeSyntax.self)?.name.text == "EnvironmentValues" else {
            throw EnvironmentValueMacroError.attachedToInvalidType
        }
        let isPublic = extensionDeclaration.modifiers.contains { $0.trimmedDescription == "public" }
        return extensionDeclaration.memberBlock.members
            .staticVariables.toEnvironmentDeclarations(isPublic: isPublic)
            .flatMap { [$0.environmentKeyDeclaration, $0.getterSetterDeclaration] }
            .map { "\(raw: $0)" }
    }
}

// MARK: Private extensions

private extension VariableDeclSyntax {
    
    var name: String? {
        bindings.first?.pattern
            .as(IdentifierPatternSyntax.self)?
            .identifier.text
    }
    
    var typeAnnotation: String? {
        bindings.first?.typeAnnotation?
            .as(TypeAnnotationSyntax.self)?
            .type.trimmedDescription
    }
    
    var initializer: String? {
        bindings.first?.initializer?.value
            .as(FunctionCallExprSyntax.self)?
            .calledExpression
            .trimmedDescription
    }
}

extension Sequence where Element == VariableDeclSyntax {
    func toEnvironmentDeclarations(isPublic: Bool) -> [EnvironmentDeclaration] {
        compactMap { variable in
            guard let name = variable.name,
                  let type = variable.typeAnnotation ?? variable.initializer else {
                return nil
            }
            return EnvironmentDeclaration(isPublic: isPublic, baseName: name, type: type)
        }
    }
}
