//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 21/4/24.
//

import Foundation
import SwiftSyntax

extension MemberBlockItemListSyntax {
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
    
    var methods: [FunctionDeclSyntax] {
        compactMap { member in
            member.decl.as(FunctionDeclSyntax.self)
        }
    }
}
