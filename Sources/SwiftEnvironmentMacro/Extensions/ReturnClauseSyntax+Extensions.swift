//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 21/4/24.
//

import Foundation
import SwiftSyntax

extension ReturnClauseSyntax {
    @inlinable func defaultReturnClause(use mappedValue: [String: String]) throws -> String {
        let value = try type.defaultValue(use: mappedValue)
        guard value != "Void()" else { return "" }
        return "return \(value)"
    }
}
