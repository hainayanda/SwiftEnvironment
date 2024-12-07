//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 21/4/24.
//

import Foundation
import SwiftSyntax

extension MemberBlockItemListSyntax {
    @inlinable var staticVariables: [VariableDeclSyntax] {
        variables.filter { $0.isStatic }
    }
    
    @inlinable var variables: [VariableDeclSyntax] {
        compactMap { member in
            member.decl.as(VariableDeclSyntax.self)
        }
    }
    
    @inlinable var initializers: [InitializerDeclSyntax] {
        compactMap { member in
            member.decl.as(InitializerDeclSyntax.self)
        }
    }
    
    @inlinable var methods: [FunctionDeclSyntax] {
        compactMap { member in
            member.decl.as(FunctionDeclSyntax.self)
        }
    }
    
    @inlinable var typeAliases: [TypeAliasDeclSyntax] {
        compactMap { member in
            member.decl.as(TypeAliasDeclSyntax.self)
        }
    }
}
