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
        return extensionDeclaration.environmentDeclaration
            .map { "\(raw: $0)" }
    }
}

struct EnvironmentDeclaration: CustomStringConvertible {
    let baseName: String
    let type: String
    
    var derivedName: String {
        "\(baseName.firstCapitalized)SwiftEnvironmentKey"
    }
    
    var description: String {
        """
        struct \(derivedName): EnvironmentKey {
            static let defaultValue: \(type) = EnvironmentValues.\(baseName)
        }
        
        var \(baseName): \(type) {
            get {
                self[\(derivedName).self]
            }
            set {
                self[\(derivedName).self] = newValue
            }
        }
        """
    }
}

// MARK: Private extensions

private extension ExtensionDeclSyntax {
    var environmentDeclaration: [EnvironmentDeclaration] {
        memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { $0.isStatic }
            .compactMap { variable in
                guard let name = variable.name,
                      let type = variable.typeAnnotation ?? variable.initializer else {
                    return nil
                }
                return EnvironmentDeclaration(baseName: name, type: type)
                
            }
    }
}

private extension VariableDeclSyntax {
    var isStatic: Bool {
        modifiers.contains {
            $0.name.text == "static"
        }
    }
    
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
