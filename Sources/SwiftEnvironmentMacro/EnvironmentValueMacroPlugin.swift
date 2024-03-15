//
//  EnvironmentValueMacroPlugin.swift
//
//
//  Created by Nayanda Haberty on 15/3/24.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct EnvironmentValueMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EnvironmentValueMacro.self
    ]
}
