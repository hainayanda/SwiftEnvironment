//
//  EnvironmentValueMacro.swift
//  
//
//  Created by Nayanda Haberty on 15/3/24.
//

import Foundation

@attached(member, names: arbitrary)
public macro EnvironmentValue(_ keys: String...) = #externalMacro(
    module: "SwiftEnvironmentMacro", type: "EnvironmentValueMacro"
)
