//
//  SwiftEnvironmentPlugin.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 31/05/25.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SwiftEnvironmentPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GlobalEntryMacro.self
    ]
} 