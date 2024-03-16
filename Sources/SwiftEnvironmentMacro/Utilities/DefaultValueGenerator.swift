//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 17/3/24.
//

import Foundation

struct DefaultValueGenerator {
    let defaultValues: [String: String]
    
    func defaultValue(for type: String) throws -> String {
        if let defaultValue = defaultValues[type] {
            return defaultValue
        } else if type.isOptionalPattern {
            return "nil"
        } else if type.isDictionaryPattern {
            return "[:]"
        } else if type.isArrayPattern {
            return "[]"
        }
        throw StubGeneratorMacroError.cannotDetermineDefaultValue(type)
    }
}

let baseDefaultValues: [String: String] = [
    "Int": "0", "Int8": "0", "Int16": "0", "Int32": "0", "Int64": "0",
    "UInt": "0", "UInt8": "0", "UInt16": "0", "UInt32": "0", "UInt64": "0",
    "Float": "0", "Float16": "0", "Float32": "0", "Float64": "0.0", "Double": "0.0",
    "Bool": "false", "Character": "Character(\"\")", "String": "\"\"", "Data": "Data()",
    "Date": "Date()", "UUID": "UUID()",
    "CGFloat": "0", "CGSize": ".zero", "CGPoint": ".zero", "CGRect": ".zero",
    "NSNumber": "0", "NSString": "\"\"", "NSNull": "NSNull()", "NSObject": "NSObject()",
    "NSData": "NSData()", "NSDate": "NSDate()", "NSSet": "NSSet()", "NSArray": "NSArray()",
    "NSSize": ".zero", "NSPoint": ".zero", "NSRect": ".zero"
]

private extension String {
    var isOptionalPattern: Bool {
        match(#"^.+\?$"#) || match(#"^Optional\s?<.+>$"#)
    }
    var isDictionaryPattern: Bool {
        match(#"^\[[^\[\(:]+:.+\]$"#) || match(#"^Dictionary\s?<.+>$"#)
    }
    var isArrayPattern: Bool {
        (match(#"^\[.+]$"#) && !isDictionaryPattern) || match(#"^Array\s?<.+>$"#)
    }
}
