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
        let keyPaths = try node.environmentValueKeyPaths
        let environmentKeys = try extensionDeclaration.environmentKeys
        return try combine(keyPaths, with: environmentKeys).map { keyPath, environmentKey in
            let keyName = environmentKey.name.text
            return """
            var \(raw: keyPath): \(raw: try environmentKey.environmentValueType) {
                get { self[\(raw: keyName).self] }
                set { self[\(raw: keyName).self] = newValue }
            }
            """
        }
    }
}

// MARK: Private functions

private func combine(
    _ keyPaths: [String],
    with environmentKeys: [StructDeclSyntax]) -> [(keyPath: String, environmentKey: StructDeclSyntax)] {
        keyPaths.enumerated().reduce(into: []) { partialResult, pair in
            partialResult.append((pair.element, environmentKeys[pair.offset]))
        }
    }

// MARK: Private extensions

private extension Array where Element: Hashable {
    var hasDuplication: Bool {
        Set(self).count > self.count
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

private extension TypeAliasDeclSyntax {
    
    var realType: String? {
        initializer.value
            .as(IdentifierTypeSyntax.self)?
            .name.text
    }
}

private extension StructDeclSyntax {
    
    var typeAliasValueRealType: String? {
        memberBlock.members
            .compactMap { $0.decl.as(TypeAliasDeclSyntax.self) }
            .first { $0.name.text == "Value" }?
            .realType
    }
    
    var environmentValueType: String {
        get throws {
            let defaultValue = memberBlock.members
                .compactMap { $0.decl.as(VariableDeclSyntax.self) }
                .first { $0.isStatic && $0.name == "defaultValue" }
            
            guard let defaultValue else {
                throw EnvironmentValueMacroError.undeterminedEnvironmentValueType
            }
            if let typeAnnotation = defaultValue.typeAnnotation,
               typeAnnotation != "Value" {
                return typeAnnotation
            }
            if let typeAliasValueRealType {
                return typeAliasValueRealType
            }
            if let initializer = defaultValue.initializer,
               initializer != "Value" {
                return initializer
            }
            throw EnvironmentValueMacroError.undeterminedEnvironmentValueType
        }
    }
}

private extension ExtensionDeclSyntax {
    var environmentKeys: [StructDeclSyntax] {
        get throws {
            let result = memberBlock.members
                .compactMap { $0.as(MemberBlockItemSyntax.self)?.decl.as(StructDeclSyntax.self) }
                .filter { $0.isEnvironmentKey }
            
            guard !result.isEmpty else {
                throw EnvironmentValueMacroError.noEnvironmentKeyProvided
            }
            let names = result.map { $0.name.text }
            
            guard !names.hasDuplication else {
                throw EnvironmentValueMacroError.duplicatedEnvironmentKeys
            }
            return result
        }
    }
}

private extension StructDeclSyntax {
    var isEnvironmentKey: Bool {
        inheritanceClause?.inheritedTypes
            .contains {
                $0.type.as(IdentifierTypeSyntax.self)?.name.text == "EnvironmentKey"
            }
        ?? false
    }
}

private extension AttributeSyntax {
    
    var environmentValueKeyPaths: [String] {
        get throws {
            guard let labeledSyntaxes = arguments?.as(LabeledExprListSyntax.self) else {
                throw EnvironmentValueMacroError.noArgumentPassed
            }
            let result = try labeledSyntaxes.map {
                guard let stringLiteral = $0.expression.as(StringLiteralExprSyntax.self),
                      let stringSegment = stringLiteral.segments.first?.as(StringSegmentSyntax.self)else {
                    throw EnvironmentValueMacroError.wrongArgumentValue
                }
                return stringSegment.content.text
            }
            guard !result.isEmpty else {
                throw EnvironmentValueMacroError.noArgumentPassed
            }
            guard !result.hasDuplication else {
                throw EnvironmentValueMacroError.duplicatedKeyPaths
            }
            return result
        }
    }
}
