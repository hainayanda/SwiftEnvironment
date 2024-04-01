//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 1/4/24.
//

import XCTest
import SwiftSyntaxMacrosTestSupport
@testable import SwiftEnvironmentMacro

// swiftlint:disable file_length
final class StubFromClassAndStructGeneratorMacroTests: XCTestCase {
    
    func test_givenSimpleStruct_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleStruct,
            expandedSource: simpleStructExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenSimpleClass_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleClass,
            expandedSource: simpleClassExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenSimpleClassWithInit_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleClassWithInit,
            expandedSource: simpleClassWithInitExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenSimpleClassWithRandomInit_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleClassWithRandomInit,
            expandedSource: simpleClassWithRandomInitExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenSimpleClassWithDifferentInit_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleClassWithDifferentInit,
            expandedSource: simpleClassWithDifferentInitExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
}

private let simpleClassWithDifferentInit: String = """
@Stubbed
class Some {
    let int: Int
    var double: Double
    let string: String = ""

    init(double: Double) {
        self.double = double
        self.int = int
    }
}
"""

private let simpleClassWithDifferentInitExpansion: String = """
class Some {
    let int: Int
    var double: Double
    let string: String = ""

    init(double: Double) {
        self.double = double
        self.int = int
    }

    static var stub: Some = Some(int: 0, double: 0.0)
    init(int: Int, double: Double) {
        self.int = int
        self.double = double
    }
}
"""

private let simpleClassWithRandomInit: String = """
@Stubbed
class Some {
    let int: Int
    var double: Double
    let string: String = ""

    init(double: Double, int: Int) {
        self.double = double
        self.int = int
    }
}
"""

private let simpleClassWithRandomInitExpansion: String = """
class Some {
    let int: Int
    var double: Double
    let string: String = ""

    init(double: Double, int: Int) {
        self.double = double
        self.int = int
    }

    static var stub: Some = Some(double: 0.0, int: 0)
}
"""

private let simpleClassWithInit: String = """
@Stubbed
class Some {
    let int: Int
    var double: Double
    let string: String = ""

    init(int: Int, double: Double) {
        self.int = int
        self.double = double
    }
}
"""

private let simpleClassWithInitExpansion: String = """
class Some {
    let int: Int
    var double: Double
    let string: String = ""

    init(int: Int, double: Double) {
        self.int = int
        self.double = double
    }

    static var stub: Some = Some(int: 0, double: 0.0)
}
"""

private let simpleClass: String = """
@Stubbed
class Some {
    let int: Int
    var double: Double
    let string: String = ""
}
"""

private let simpleClassExpansion: String = """
class Some {
    let int: Int
    var double: Double
    let string: String = ""

    static var stub: Some = Some(int: 0, double: 0.0)
    init(int: Int, double: Double) {
        self.int = int
        self.double = double
    }
}
"""

private let simpleStruct: String = """
@Stubbed
struct Some {
    let int: Int
    var double: Double
    let string: String = ""
}
"""

private let simpleStructExpansion: String = """
struct Some {
    let int: Int
    var double: Double
    let string: String = ""

    static var stub: Some = Some(int: 0, double: 0.0)
}
"""
