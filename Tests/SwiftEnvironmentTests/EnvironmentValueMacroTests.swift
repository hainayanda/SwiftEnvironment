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
        assertMacroExpansion("""
            @EnvironmentValue("dummy")
            extension EnvironmentValues {
                struct DummyEnvironmentKey: EnvironmentKey {
                    static let defaultValue: DummyDependency = DummyDependency()
                }
            }
            """, expandedSource: """
            
            extension EnvironmentValues {
                struct DummyEnvironmentKey: EnvironmentKey {
                    static let defaultValue: DummyDependency = DummyDependency()
                }
            
                var dummy: DummyDependency {
                    get {
                        self [DummyEnvironmentKey.self]
                    }
                    set {
                        self [DummyEnvironmentKey.self] = newValue
                    }
                }
            }
            """, macros: ["EnvironmentValue": EnvironmentValueMacro.self])
    }
    
    func test_givenOneArgumentWithTypeAliases_whenExpanded_shouldAddProperty() {
        assertMacroExpansion("""
            @EnvironmentValue("dummy")
            extension EnvironmentValues {
                struct DummyEnvironmentKey: EnvironmentKey {
                    typealias Value = DummyDependency
                    static let defaultValue: Value = DummyDependency()
                }
            }
            """, expandedSource: """
            
            extension EnvironmentValues {
                struct DummyEnvironmentKey: EnvironmentKey {
                    typealias Value = DummyDependency
                    static let defaultValue: Value = DummyDependency()
                }
            
                var dummy: DummyDependency {
                    get {
                        self [DummyEnvironmentKey.self]
                    }
                    set {
                        self [DummyEnvironmentKey.self] = newValue
                    }
                }
            }
            """, macros: ["EnvironmentValue": EnvironmentValueMacro.self])
    }
    
    func test_givenOneArgumentWithNoTypeAnnotation_whenExpanded_shouldAddProperty() {
        assertMacroExpansion("""
            @EnvironmentValue("dummy")
            extension EnvironmentValues {
                struct DummyEnvironmentKey: EnvironmentKey {
                    static let defaultValue = DummyDependency()
                }
            }
            """, expandedSource: """
            
            extension EnvironmentValues {
                struct DummyEnvironmentKey: EnvironmentKey {
                    static let defaultValue = DummyDependency()
                }
            
                var dummy: DummyDependency {
                    get {
                        self [DummyEnvironmentKey.self]
                    }
                    set {
                        self [DummyEnvironmentKey.self] = newValue
                    }
                }
            }
            """, macros: ["EnvironmentValue": EnvironmentValueMacro.self])
    }
    
    func test_givenMultipleArguments_whenExpanded_shouldAddProperties() {
        assertMacroExpansion("""
            @EnvironmentValue("one", "two", "three")
            extension EnvironmentValues {
                struct DummyEnvironmentKeyOne: EnvironmentKey {
                    static let defaultValue: DummyDependency = DummyDependency()
                }
                struct DummyEnvironmentKeyTwo: EnvironmentKey {
                    static let defaultValue: DummyDependency = DummyDependency()
                }
                struct DummyEnvironmentKeyThree: EnvironmentKey {
                    static let defaultValue: DummyDependency = DummyDependency()
                }
            }
            """, expandedSource: """
            
            extension EnvironmentValues {
                struct DummyEnvironmentKeyOne: EnvironmentKey {
                    static let defaultValue: DummyDependency = DummyDependency()
                }
                struct DummyEnvironmentKeyTwo: EnvironmentKey {
                    static let defaultValue: DummyDependency = DummyDependency()
                }
                struct DummyEnvironmentKeyThree: EnvironmentKey {
                    static let defaultValue: DummyDependency = DummyDependency()
                }
            
                var one: DummyDependency {
                    get {
                        self [DummyEnvironmentKeyOne.self]
                    }
                    set {
                        self [DummyEnvironmentKeyOne.self] = newValue
                    }
                }
            
                var two: DummyDependency {
                    get {
                        self [DummyEnvironmentKeyTwo.self]
                    }
                    set {
                        self [DummyEnvironmentKeyTwo.self] = newValue
                    }
                }
            
                var three: DummyDependency {
                    get {
                        self [DummyEnvironmentKeyThree.self]
                    }
                    set {
                        self [DummyEnvironmentKeyThree.self] = newValue
                    }
                }
            }
            """, macros: ["EnvironmentValue": EnvironmentValueMacro.self])
    }
}