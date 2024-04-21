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
    
    func test_givenSimpleStructWithClosure_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleStructWithClosure,
            expandedSource: simpleStructWithClosureExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenSimpleClasstWithClosure_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleClassWithClosure,
            expandedSource: simpleClassWithClosureExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenSimpleStructWithOptional_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleStructWithOptional,
            expandedSource: simpleStructWithOptionalExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
}

private let simpleStructWithOptional: String = """
@Stubbed
struct Some {
    let optionalClosure: (() -> Void)?
    let optionalInt: Int?
    let optionalArray: [Int]?
    let optionalTupple: (Int?, Double?)
    let realOptional: Optional<Int>
}
"""

private let simpleStructWithOptionalExpansion: String = """
struct Some {
    let optionalClosure: (() -> Void)?
    let optionalInt: Int?
    let optionalArray: [Int]?
    let optionalTupple: (Int?, Double?)
    let realOptional: Optional<Int>

    static var stub: Some {
        Some(optionalClosure: nil, optionalInt: nil, optionalArray: nil, optionalTupple: (nil, nil), realOptional: nil)
    }
}
"""

private let simpleClassWithClosure: String = """
@Stubbed
class Some {
    let voidClosure: () -> Void
    let argVoidClosure: (Int) -> Void
    let argsVoidClosure: (Int, Int) -> Void
    let returnClosure: () -> Int?
    let argReturnClosure: (Int) -> [Int]
    let argsReturnClosure: (Int, Int) -> Int
}
"""

private let simpleClassWithClosureExpansion: String = """
class Some {
    let voidClosure: () -> Void
    let argVoidClosure: (Int) -> Void
    let argsVoidClosure: (Int, Int) -> Void
    let returnClosure: () -> Int?
    let argReturnClosure: (Int) -> [Int]
    let argsReturnClosure: (Int, Int) -> Int

    static var stub: Some {
        Some(voidClosure: {
            }, argVoidClosure: { _ in
            }, argsVoidClosure: { _, _ in
            }, returnClosure: {
                return nil
            }, argReturnClosure: { _ in
                return []
            }, argsReturnClosure: { _, _ in
                return 0
            })
    }
    init(voidClosure: () -> Void, argVoidClosure: (Int) -> Void, argsVoidClosure: (Int, Int) -> Void, returnClosure: () -> Int?, argReturnClosure: (Int) -> [Int], argsReturnClosure: (Int, Int) -> Int) {
        self.voidClosure = voidClosure
        self.argVoidClosure = argVoidClosure
        self.argsVoidClosure = argsVoidClosure
        self.returnClosure = returnClosure
        self.argReturnClosure = argReturnClosure
        self.argsReturnClosure = argsReturnClosure
    }
}
"""

private let simpleStructWithClosure: String = """
@Stubbed
struct Some {
    let voidClosure: () -> Void
    let argVoidClosure: (Int) -> Void
    let argsVoidClosure: (Int, Int) -> Void
    let returnClosure: () -> Int
    let argReturnClosure: (Int) -> Int
    let argsReturnClosure: (Int, Int) -> Int
}
"""

private let simpleStructWithClosureExpansion: String = """
struct Some {
    let voidClosure: () -> Void
    let argVoidClosure: (Int) -> Void
    let argsVoidClosure: (Int, Int) -> Void
    let returnClosure: () -> Int
    let argReturnClosure: (Int) -> Int
    let argsReturnClosure: (Int, Int) -> Int

    static var stub: Some {
        Some(voidClosure: {
            }, argVoidClosure: { _ in
            }, argsVoidClosure: { _, _ in
            }, returnClosure: {
                return 0
            }, argReturnClosure: { _ in
                return 0
            }, argsReturnClosure: { _, _ in
                return 0
            })
    }
}
"""

private let simpleClassWithDifferentInit: String = """
@Stubbed
class Some {
    let int: Int
    var double: Double
    let string: String = ""

    init(double: Double) {
        self.double = double
        self.int = 0
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
        self.int = 0
    }

    static var stub: Some {
        Some(int: 0, double: 0.0)
    }
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

    static var stub: Some {
        Some(double: 0.0, int: 0)
    }
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

    static var stub: Some {
        Some(int: 0, double: 0.0)
    }
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

    static var stub: Some {
        Some(int: 0, double: 0.0)
    }
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

    static var stub: Some {
        Some(int: 0, double: 0.0)
    }
}
"""
