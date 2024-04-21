//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 21/4/24.
//

import Foundation

struct EnvironmentDeclaration: CustomStringConvertible {
    let isPublic: Bool
    let baseName: String
    let type: String
    
    var derivedName: String {
        "\(baseName.firstCapitalized)SwiftEnvironmentKey"
    }
    var accessModifier: String {
        isPublic ? "public " : ""
    }
    
    var description: String {
        """
        struct \(derivedName): EnvironmentKey {
            \(accessModifier)static let defaultValue: \(type) = EnvironmentValues.\(baseName)
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
