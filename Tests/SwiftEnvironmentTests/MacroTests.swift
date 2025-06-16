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
            GlobalValues.atomicRead {
                self[\.dummy] ?? GlobalValues.___dummy.value
            }
        }
    }

    private static let ___dummy: ___ValueWrapper_dummy = ___ValueWrapper_dummy()

    private struct ___ValueWrapper_dummy: @unchecked Sendable {
        let value: DummyDependency = DummyClass()
    }
}
"""#
#endif
