//
//  Macros.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 31/05/25.
//

import Foundation

@attached(accessor)
@attached(peer, names: prefixed(___))
public macro GlobalEntry() = #externalMacro(
    module: "SwiftEnvironmentMacro", type: "GlobalEntryMacro"
)
