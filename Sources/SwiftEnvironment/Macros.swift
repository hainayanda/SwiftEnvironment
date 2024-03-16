//
//  Macros.swift
//
//
//  Created by Nayanda Haberty on 15/3/24.
//

import Foundation

@attached(member, names: arbitrary)
public macro EnvironmentValue(_ keys: String...) = #externalMacro(
    module: "SwiftEnvironmentMacro", type: "EnvironmentValueMacro"
)

@attached(peer, names: suffixed(Stub))
public macro Stubbed(name: String? = nil, type: StubType = .struct) = #externalMacro(
    module: "SwiftEnvironmentMacro", type: "StubGeneratorMacro"
)

@attached(peer, names: suffixed(Stub))
public macro Stubbed(name: String? = nil, type: StubType = .struct, _ values: DefaultType...) = #externalMacro(
    module: "SwiftEnvironmentMacro", type: "StubGeneratorMacro"
)

public enum StubType {
    case `struct`
    case `class`
    case subclass(AnyClass.Type)
}

public struct DefaultType {
    public static func value<T>(for: T.Type, _: T) -> DefaultType {
        DefaultType()
    }
}
