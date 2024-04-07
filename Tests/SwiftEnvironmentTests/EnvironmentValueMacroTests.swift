//
//  EnvironmentValueMacroTests.swift
//
//
//  Created by Nayanda Haberty on 15/3/24.
//

import XCTest
import SwiftSyntaxMacrosTestSupport
@testable import SwiftEnvironmentMacro

final class EnvironmentValueMacroTests: XCTestCase {
    
    func test_givenOneArgument_whenExpanded_shouldAddProperty() {
        assertMacroExpansion(
            oneArg, expandedSource: oneArgExpansion,
            macros: ["EnvironmentValue": EnvironmentValueMacro.self]
        )
    }
    
    func test_givenOneArgumentWithNoTypeAnnotation_whenExpanded_shouldAddProperty() {
        assertMacroExpansion(
            oneArgNoType, expandedSource: oneArgNoTypeExpansion,
            macros: ["EnvironmentValue": EnvironmentValueMacro.self]
        )
    }
    
    func test_givenMultipleArguments_whenExpanded_shouldAddProperties() {
        assertMacroExpansion(
            multiArgs, expandedSource: multiArgsExpansion,
            macros: ["EnvironmentValue": EnvironmentValueMacro.self]
        )
    }
    
    func test_givenOneGenericArgument_whenExpanded_shouldAddProperty() {
        assertMacroExpansion(
            oneGenericArg, expandedSource: oneGenericArgExpansion,
            macros: ["EnvironmentValue": EnvironmentValueMacro.self]
        )
    }
    
    func test_givenOneImplicitArgument_whenExpanded_shouldAddProperty() {
        assertMacroExpansion(
            oneImplicitArg, expandedSource: oneImplicitArgExpansion,
            macros: ["EnvironmentValue": EnvironmentValueMacro.self]
        )
    }
}

private let oneImplicitArg: String = """
@EnvironmentValue
public extension EnvironmentValues {
    static let dummy = Some.Dependency()
}
"""

private let oneImplicitArgExpansion: String = """

public extension EnvironmentValues {
    static let dummy = Some.Dependency()

    struct DummySwiftEnvironmentKey: EnvironmentKey {
        public static let defaultValue: Some.Dependency = EnvironmentValues.dummy
    }

    var dummy: Some.Dependency {
        get {
            self[DummySwiftEnvironmentKey.self]
        }
        set {
            self[DummySwiftEnvironmentKey.self] = newValue
        }
    }
}
"""

private let oneGenericArg: String = """
@EnvironmentValue("dummy")
extension EnvironmentValues {
    static let dummy: Dependency<Some> = DummyDependency()
}
"""

private let oneGenericArgExpansion: String = """

extension EnvironmentValues {
    static let dummy: Dependency<Some> = DummyDependency()

    struct DummySwiftEnvironmentKey: EnvironmentKey {
        static let defaultValue: Dependency<Some> = EnvironmentValues.dummy
    }

    var dummy: Dependency<Some> {
        get {
            self[DummySwiftEnvironmentKey.self]
        }
        set {
            self[DummySwiftEnvironmentKey.self] = newValue
        }
    }
}
"""

private let oneArg: String = """
@EnvironmentValue
public extension EnvironmentValues {
    static let dummy: DummyDependency = DummyDependency()
}
"""

private let oneArgExpansion: String = """

public extension EnvironmentValues {
    static let dummy: DummyDependency = DummyDependency()

    struct DummySwiftEnvironmentKey: EnvironmentKey {
        public static let defaultValue: DummyDependency = EnvironmentValues.dummy
    }

    var dummy: DummyDependency {
        get {
            self[DummySwiftEnvironmentKey.self]
        }
        set {
            self[DummySwiftEnvironmentKey.self] = newValue
        }
    }
}
"""

private let oneArgNoType: String = """
@EnvironmentValue
extension EnvironmentValues {
    static let dummy = DummyDependency()
}
"""

private let oneArgNoTypeExpansion: String = """

extension EnvironmentValues {
    static let dummy = DummyDependency()

    struct DummySwiftEnvironmentKey: EnvironmentKey {
        static let defaultValue: DummyDependency = EnvironmentValues.dummy
    }

    var dummy: DummyDependency {
        get {
            self[DummySwiftEnvironmentKey.self]
        }
        set {
            self[DummySwiftEnvironmentKey.self] = newValue
        }
    }
}
"""

private let multiArgs: String = """
@EnvironmentValue("one", "two", "three")
public extension EnvironmentValues {
    static let one = DummyDependency()
    static let two = DummyDependency()
    static let three = DummyDependency()
}
"""

private let multiArgsExpansion: String = """

public extension EnvironmentValues {
    static let one = DummyDependency()
    static let two = DummyDependency()
    static let three = DummyDependency()

    struct OneSwiftEnvironmentKey: EnvironmentKey {
        public static let defaultValue: DummyDependency = EnvironmentValues.one
    }

    var one: DummyDependency {
        get {
            self[OneSwiftEnvironmentKey.self]
        }
        set {
            self[OneSwiftEnvironmentKey.self] = newValue
        }
    }

    struct TwoSwiftEnvironmentKey: EnvironmentKey {
        public static let defaultValue: DummyDependency = EnvironmentValues.two
    }

    var two: DummyDependency {
        get {
            self[TwoSwiftEnvironmentKey.self]
        }
        set {
            self[TwoSwiftEnvironmentKey.self] = newValue
        }
    }

    struct ThreeSwiftEnvironmentKey: EnvironmentKey {
        public static let defaultValue: DummyDependency = EnvironmentValues.three
    }

    var three: DummyDependency {
        get {
            self[ThreeSwiftEnvironmentKey.self]
        }
        set {
            self[ThreeSwiftEnvironmentKey.self] = newValue
        }
    }
}
"""
