//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 1/4/24.
//

import Foundation
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntax

extension StubGeneratorMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard  let name = declaration.className ?? declaration.structName else {
            return []
        }
        let isClass = declaration.isClass
        let defaultValues = try node.defaultValueArguments
            .reduce(into: baseDefaultValues) { partialResult, pair in
                partialResult[pair.key] = pair.value
            }
        
        let initArguments = declaration.memberBlock.members
            .initializers.map { $0.arguments }
        
        var arguments = try declaration.memberBlock.members
            .variables.patternBindings.withNoInitializers
            .toArgumentPairs(use: defaultValues)
        
        let matchedInit = initArguments.first { $0.initArgumentsMatch(arguments: arguments) }
        if let matchedInit {
            arguments = try arguments.sortToMatch(initArguments: matchedInit)
        }
        
        let stubInitializer = StubInitializer(name: name, generateInit: matchedInit == nil && isClass, argumentPairs: arguments)
        return ["\(raw: stubInitializer.description)"]
    }
}

private extension DeclGroupSyntax {
    var structName: String? {
        self.as(StructDeclSyntax.self)?.name.trimmedDescription
    }
    var className: String? {
        self.as(ClassDeclSyntax.self)?.name.trimmedDescription
    }
    var isClass: Bool {
        self.as(ClassDeclSyntax.self) != nil
    }
}

private extension MemberBlockItemListSyntax {
    var variables: [VariableDeclSyntax] {
        compactMap { member in
            member.decl.as(VariableDeclSyntax.self)
        }
    }
    
    var initializers: [InitializerDeclSyntax] {
        compactMap { member in
            member.decl.as(InitializerDeclSyntax.self)
        }
    }
}

private extension InitializerDeclSyntax {
    var arguments: [InitArgumentPairs] {
        signature.parameterClause.parameters.map { parameter in
            InitArgumentPairs(
                name: (parameter.secondName ?? parameter.firstName).trimmedDescription,
                type: parameter.type.trimmedDescription
            )
        }
    }
}

private extension TypeSyntax {
    func defaultValue(use mappedValue: [String: String]) throws -> String {
        if let value = mappedValue[description] {
            return value
        } else if description.match(#"^(Void|\(\s*\))$"#) {
            return "Void()"
        } else if self.as(OptionalTypeSyntax.self) != nil || description.match(#"^Optional<.+>$"#) {
            return "nil"
        } else if self.as(ArrayTypeSyntax.self) != nil {
            return "[]"
        } else if let function = self.as(FunctionTypeSyntax.self) {
            let argumentCount = function.parameters.as(TupleTypeElementListSyntax.self)?.count ?? 0
            let arguments = (0..<argumentCount).reduce("") { partialResult, _ in
                if partialResult.isEmpty { return "_" }
                return "\(partialResult), _"
            }
            let argumentsClause = arguments.isEmpty ? "" : "\(arguments) in"
            let returnClause = try function.returnClause.defaultReturnClause(use: mappedValue)
            return "{ \(argumentsClause) \(returnClause) }"
        } else if let tuple = self.as(TupleTypeSyntax.self) {
            let partial = try tuple.elements.map { element in
                try element.type.defaultValue(use: mappedValue)
            }
            .reduce("") { partialResult, value in
                if partialResult.isEmpty { return value }
                return "\(partialResult), \(value)"
            }
            return "(\(partial))"
        } else {
            throw StubGeneratorMacroError.cannotDetermineDefaultValue(description)
        }
    }
}

private extension ReturnClauseSyntax {
    func defaultReturnClause(use mappedValue: [String: String]) throws -> String {
        let value = try type.defaultValue(use: mappedValue)
        guard value != "Void()" else { return "" }
        return "return \(value)"
    }
}

private extension Array where Element == InitArgumentPairs {
    func initArgumentsMatch(arguments: [InitArgumentPairs]) -> Bool {
        guard arguments.count == self.count else { return false }
        for argument in arguments {
            let inInit: Bool = contains {
                $0.name == argument.name && $0.type == argument.type
            }
            guard inInit else { return false }
        }
        return true
    }
    
    func sortToMatch(initArguments: [InitArgumentPairs]) throws -> [InitArgumentPairs] {
        try initArguments.map { arg in
            let element = first { $0.name == arg.name && $0.type == arg.type }
            guard let element else {
                throw StubGeneratorMacroError.failedToExtractVariables
            }
            return element
        }
    }
}

private extension Sequence where Element == VariableDeclSyntax {
    var patternBindings: [PatternBindingSyntax] {
        compactMap { declaration in
            guard declaration.bindings.count == 1,
                  let binding = declaration.bindings.first?.as(PatternBindingSyntax.self) else {
                return nil
            }
            return binding
        }
    }
}

private extension Sequence where Element == PatternBindingSyntax {
    var withNoInitializers: [PatternBindingSyntax] {
        filter { binding in
            binding.initializer == nil
        }
    }
    func toArgumentPairs(use mappedValue: [String: String]) throws -> [InitArgumentPairs] {
        try map { binding in
            guard let type = binding.typeAnnotation?.type else {
                throw StubGeneratorMacroError.cannotDetermineType(binding.pattern.trimmedDescription)
            }
            let value = try type.defaultValue(use: mappedValue)
            return InitArgumentPairs(name: binding.pattern.trimmedDescription, type: type.description, value: value)
        }
    }
}
