//
//  MacroTests.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 14/06/25.
//

#if canImport(SwiftEnvironmentMacro) // macro generation can only be run on macos (on pre-compiling phase)
import XCTest
import SwiftSyntaxMacrosTestSupport
@testable import SwiftEnvironmentMacro

final class MacroTests: XCTestCase {
    
    func test_givenBasicEntry_whenExpanded_shouldUseBasicExpansion() {
        assertMacroExpansion(
            basic, expandedSource: basicExpansion,
            macros: ["GlobalEntry": GlobalEntryMacro.self]
        )
    }
    
    func test_givenIsolatedEntry_whenExpanded_shouldUseIsolatedExpansion() {
        assertMacroExpansion(
            isolated, expandedSource: isolatedExpansion,
            macros: ["GlobalEntry": GlobalEntryMacro.self]
        )
    }
}

private let basic = #"""
extension GlobalValues {
    @GlobalEntry var dummy: DummyDependency = DummyClass()
}
"""#

private let basicExpansion = #"""
extension GlobalValues {
    var dummy: DummyDependency {
        get {
            self[\.dummy] ?? GlobalValues.___dummy
        }
    }

    nonisolated(unsafe) private static let ___dummy: DummyDependency = DummyClass()
}
"""#

private let isolated = #"""
extension GlobalValues {
    @GlobalEntry(.isolated) var dummy: DummyDependency = DummyClass()
}
"""#

private let isolatedExpansion = #"""
extension GlobalValues {
    var dummy: DummyDependency {
        get {
            self[\.dummy] ?? GlobalValues.___dummy
        }
    }

    private static let ___dummy: DummyDependency = DummyClass()
}
"""#
#endif
