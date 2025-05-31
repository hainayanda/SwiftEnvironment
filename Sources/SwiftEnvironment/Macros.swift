//
//  Macros.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 31/05/25.
//

@attached(accessor)
public macro GlobalEntry() = #externalMacro(
    module: "SwiftEnvironmentMacro", type: "GlobalEntryMacro"
)
