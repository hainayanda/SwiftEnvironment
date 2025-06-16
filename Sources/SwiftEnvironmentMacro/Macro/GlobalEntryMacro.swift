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
                    GlobalValues.atomicRead {
                        self[\\.\(raw: varName)] ?? GlobalValues.___\(raw: varName)
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
        let modifier = isIsolated(node, typeAnnotation: typeAnnotation) ? "" : "nonisolated(unsafe) "
        return [
            DeclSyntax(
                """
                \(raw: modifier)private static let ___\(raw: varName): \(raw: typeAnnotation.type.trimmedDescription) = \(initializer)
                """
            )
        ]
    }
    
    private static func isIsolated(_ node: AttributeSyntax, typeAnnotation: TypeAnnotationSyntax) -> Bool {
        guard !isDefaultSendable(typeAnnotation.type) else {
            return true
        }
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
              let firstArgument = arguments.first,
              let expression = firstArgument.expression.as(MemberAccessExprSyntax.self) else {
            return false
        }
        let description = expression.trimmedDescription
        return description == ".isolated" || description == "StaticModifier.isolated"
    }
    
    private static func isDefaultSendable(_ typeSyntax: TypeSyntax) -> Bool {
        switch typeSyntax.as(TypeSyntaxEnum.self) {
            
            // Simple identifier like Int, String, etc.
        case .identifierType(let simpleType):
            let name = simpleType.name.trimmed.text
            return defaultSendableNames.contains(name) || qualifiedSendableNames.contains(simpleType.description)
            
            // Optional like Int? or Optional<Int>
        case .optionalType(let optionalType):
            return isDefaultSendable(optionalType.wrappedType)
            
            // Array like [Int] or Array<Int>
        case .arrayType(let arrayType):
            return isDefaultSendable(arrayType.element)
            
            // Dictionary like [String: Int]
        case .dictionaryType(let dictType):
            return isDefaultSendable(dictType.key) && isDefaultSendable(dictType.value)
            
            // Tuple like (Int, String)
        case .tupleType(let tupleType):
            return tupleType.elements.allSatisfy { isDefaultSendable($0.type) }
            
            // Attributed or parenthesized types
        case .attributedType(let attrType):
            return isDefaultSendable(attrType.baseType)
            
        case .someOrAnyType(let someType): // for e.g. some Sendable
            return isDefaultSendable(someType.constraint)
            
        default:
            return false
        }
    }
    
    private static let defaultSendableNames: Set<String> = {
        Set(qualifiedSendableNames.compactMap { $0.components(separatedBy: ".").last })
    }()
    
    private static let qualifiedSendableNames: Set<String> = [
        // Swift primitives
        "Swift.Int", "Swift.Int8", "Swift.Int16", "Swift.Int32", "Swift.Int64",
        "Swift.UInt", "Swift.UInt8", "Swift.UInt16", "Swift.UInt32", "Swift.UInt64",
        "Swift.Double", "Swift.Float", "Swift.Float16", "CoreGraphics.CGFloat",
        "Swift.Bool", "Swift.String", "Swift.Character", "Swift.StaticString",
        "Swift.Void", "Swift.Never",
        
        // Foundation structs
        "Foundation.Data", "Foundation.Date", "Foundation.UUID", "Foundation.URL", "Foundation.Decimal",
        "Foundation.IndexPath", "Foundation.IndexSet",
        "Foundation.TimeZone", "Foundation.Locale", "Foundation.Calendar",
        "Foundation.Measurement", "Foundation.DateComponents", "Foundation.URLComponents",
        "Foundation.URLRequest", "Foundation.URLResponse", "Foundation.TimeInterval",
        
        // CoreGraphics
        "CoreGraphics.CGPoint", "CoreGraphics.CGSize", "CoreGraphics.CGRect", "CoreGraphics.CGVector", "CoreGraphics.CGAffineTransform",
        
        // Ranges
        "Swift.Range", "Swift.ClosedRange", "Swift.StrideThrough", "Swift.StrideTo",
        
        // UIKit
        "UIKit.UIEdgeInsets", "UIKit.UIOffset",
        
        // SwiftUI
        "SwiftUI.Angle", "SwiftUI.EdgeInsets"
    ]
    
}
