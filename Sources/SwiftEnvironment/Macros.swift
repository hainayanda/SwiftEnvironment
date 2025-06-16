//
//  Macros.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 31/05/25.
//

import Foundation

@attached(accessor)
@attached(peer, names: prefixed(___), prefixed(___ValueWrapper_))
public macro GlobalEntry() = #externalMacro(
    module: "SwiftEnvironmentMacro", type: "GlobalEntryMacro"
)
