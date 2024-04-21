//
//  File.swift
//
//
//  Created by Nayanda Haberty on 17/3/24.
//

import Foundation
import SwiftSyntax

let baseDefaultValues: [String: String] = [
    "Int": "0", "Int8": "0", "Int16": "0", "Int32": "0", "Int64": "0",
    "UInt": "0", "UInt8": "0", "UInt16": "0", "UInt32": "0", "UInt64": "0",
    "Float": "0", "Float16": "0", "Float32": "0", "Float64": "0.0", "Double": "0.0",
    "Bool": "false", "Character": "Character(\"\")", "String": "\"\"", "Data": "Data()",
    "Date": "Date()", "UUID": "UUID()",
    "CGFloat": "0", "CGSize": ".zero", "CGPoint": ".zero", "CGRect": ".zero",
    "NSNumber": "0", "NSString": "\"\"", "NSNull": "NSNull()", "NSObject": "NSObject()",
    "NSData": "NSData()", "NSDate": "NSDate()", "NSSet": "NSSet()", "NSArray": "NSArray()",
    "NSSize": ".zero", "NSPoint": ".zero", "NSRect": ".zero",
    "AnyView": "AnyView(EmptyView())"
]
