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
    
    func test_givenSendableEntry_whenExpanded_shouldUseSendableExpansion() {
        assertMacroExpansion(
            defaultSendable, expandedSource: defaultSendableExpansion,
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
                self[\.dummy] ?? GlobalValues.___dummy
            }
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
            GlobalValues.atomicRead {
                self[\.dummy] ?? GlobalValues.___dummy
            }
        }
    }

    private static let ___dummy: DummyDependency = DummyClass()
}
"""#

private let defaultSendable = #"""
extension GlobalValues {
    @GlobalEntry var dummy1: String = ""
    @GlobalEntry var dummy2: [String] = []
    @GlobalEntry var dummy3: String? = nil
}
"""#

private let defaultSendableExpansion = #"""
extension GlobalValues {
    var dummy1: String {
        get {
            GlobalValues.atomicRead {
                self[\.dummy1] ?? GlobalValues.___dummy1
            }
        }
    }

    private static let ___dummy1: String = ""
    var dummy2: [String] {
        get {
            GlobalValues.atomicRead {
                self[\.dummy2] ?? GlobalValues.___dummy2
            }
        }
    }

    private static let ___dummy2: [String] = []
    var dummy3: String? {
        get {
            GlobalValues.atomicRead {
                self[\.dummy3] ?? GlobalValues.___dummy3
            }
        }
    }

    private static let ___dummy3: String? = nil
}
"""#
#endif
