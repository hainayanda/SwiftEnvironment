//
//  Macros.swift
//
//
//  Created by Nayanda Haberty on 15/3/24.
//

import Foundation

@attached(member, names: arbitrary)
public macro EnvironmentValue() = #externalMacro(
    module: "SwiftEnvironmentMacro", type: "EnvironmentValueMacro"
)

@attached(member, names: arbitrary)
public macro Stubbed(public: Bool = false) = #externalMacro(
    module: "SwiftEnvironmentMacro", type: "StubFromTypeGeneratorMacro"
)

@attached(member, names: arbitrary)
public macro Stubbed(public: Bool = false, _ values: DefaultType...) = #externalMacro(
    module: "SwiftEnvironmentMacro", type: "StubFromTypeGeneratorMacro"
)

@attached(peer, names: suffixed(Stub))
public macro Stubbed(type: StubType) = #externalMacro(
    module: "SwiftEnvironmentMacro", type: "StubGeneratorMacro"
)

@attached(peer, names: suffixed(Stub))
public macro Stubbed(type: StubType, _ values: DefaultType...) = #externalMacro(
    module: "SwiftEnvironmentMacro", type: "StubGeneratorMacro"
)

public enum StubType {
    case `struct`
    case `class`
    case openClass
    case subclass(AnyClass.Type)
    case openSubclass(AnyClass.Type)
}

public struct DefaultType {
    public static func value<T>(for: T.Type, _: T) -> DefaultType {
        DefaultType()
    }
}
