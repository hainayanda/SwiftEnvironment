//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 17/3/24.
//

import Foundation

struct MethodProtocolDeclaration: CustomStringConvertible {
    let wholeDeclaration: String
    let returnClause: String
    
    @inlinable var description: String {
        "\(wholeDeclaration) { \(returnClause) }"
    }
}
