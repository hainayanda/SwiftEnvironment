//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 21/4/24.
//

import Foundation
import SwiftSyntax

extension Sequence where Element == VariableDeclSyntax {
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
