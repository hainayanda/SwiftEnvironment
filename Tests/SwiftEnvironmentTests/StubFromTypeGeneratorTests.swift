//
//  File.swift
//  
//
//  Created by Nayanda Haberty on 1/4/24.
//

#if os(macOS)
import XCTest
import SwiftSyntaxMacrosTestSupport
@testable import SwiftEnvironmentMacro

// swiftlint:disable file_length
final class StubFromClassAndStructGeneratorMacroTests: XCTestCase {
    
    func test_givenSimpleStruct_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleStruct,
            expandedSource: simpleStructExpansion,
            macros: ["Stubbed": StubFromTypeGeneratorMacro.self]
        )
    }
    
    func test_givenSimpleClass_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleClass,
            expandedSource: simpleClassExpansion,
            macros: ["Stubbed": StubFromTypeGeneratorMacro.self]
        )
    }
    
    func test_givenSimpleClassWithInit_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleClassWithInit,
            expandedSource: simpleClassWithInitExpansion,
            macros: ["Stubbed": StubFromTypeGeneratorMacro.self]
        )
    }
    
    func test_givenSimpleClassWithRandomInit_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleClassWithRandomInit,
            expandedSource: simpleClassWithRandomInitExpansion,
            macros: ["Stubbed": StubFromTypeGeneratorMacro.self]
        )
    }
    
    func test_givenSimpleClassWithDifferentInit_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleClassWithDifferentInit,
            expandedSource: simpleClassWithDifferentInitExpansion,
            macros: ["Stubbed": StubFromTypeGeneratorMacro.self]
        )
    }
    
    func test_givenSimpleStructWithClosure_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleStructWithClosure,
            expandedSource: simpleStructWithClosureExpansion,
            macros: ["Stubbed": StubFromTypeGeneratorMacro.self]
        )
    }
    
    func test_givenSimpleClasstWithClosure_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleClassWithClosure,
            expandedSource: simpleClassWithClosureExpansion,
            macros: ["Stubbed": StubFromTypeGeneratorMacro.self]
        )
    }
    
    func test_givenSimpleStructWithOptional_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleStructWithOptional,
            expandedSource: simpleStructWithOptionalExpansion,
            macros: ["Stubbed": StubFromTypeGeneratorMacro.self]
        )
    }
    
    func test_givenSimpleStructWithTypeAlias_shouldGenerateDefault() {
        assertMacroExpansion(
            typeAliasStruct,
            expandedSource: typeAliasStructExpansion,
            macros: ["Stubbed": StubFromTypeGeneratorMacro.self]
        )
    }
    
    func test_givenUnknownTypeStruct_shouldGenerateDefault() {
        assertMacroExpansion(
            unknownTypeStruct,
            expandedSource: unknownTypeStructExpansion,
            macros: ["Stubbed": StubFromTypeGeneratorMacro.self]
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

typealias SomeStub = Some
"""

private let simpleClassWithClosure: String = """
@Stubbed(public: true)
class Some {
    let voidClosure: () -> Void
    let argVoidClosure: (Int) -> Void
    let argsVoidClosure: (Int, Int) -> Void
    let returnClosure: () -> Int?
    let argReturnClosure: (Int) -> [Int]
    let argsReturnClosure: (Int, Int) -> Int
}
"""
// swiftlint:disable line_length
private let simpleClassWithClosureExpansion: String = """
class Some {
    let voidClosure: () -> Void
    let argVoidClosure: (Int) -> Void
    let argsVoidClosure: (Int, Int) -> Void
    let returnClosure: () -> Int?
    let argReturnClosure: (Int) -> [Int]
    let argsReturnClosure: (Int, Int) -> Int

    public static var stub: Some {
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

typealias SomeStub = Some
"""
// swiftlint:enable line_length

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

typealias SomeStub = Some
"""

private let simpleClassWithDifferentInit: String = """
@Stubbed(public: true)
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

    public static var stub: Some {
        Some(int: 0, double: 0.0)
    }

    init(int: Int, double: Double) {
        self.int = int
        self.double = double
    }
}

typealias SomeStub = Some
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

typealias SomeStub = Some
"""

private let simpleClassWithInit: String = """
@Stubbed(public: true)
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

    public static var stub: Some {
        Some(int: 0, double: 0.0)
    }
}

typealias SomeStub = Some
"""

private let simpleClass: String = """
@Stubbed
public class Some {
    let int: Int
    var double: Double
    let string: String = ""
}
"""

private let simpleClassExpansion: String = """
public class Some {
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

public typealias SomeStub = Some
"""

private let simpleStruct: String = """
@Stubbed(public: true)
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

    public static var stub: Some {
        Some(int: 0, double: 0.0)
    }
}

typealias SomeStub = Some
"""

private let typeAliasStruct: String = """
@Stubbed
public struct Some {
    typealias MyAlias = Int
    let int: MyAlias
}
"""

private let typeAliasStructExpansion: String = """
public struct Some {
    typealias MyAlias = Int
    let int: MyAlias

    static var stub: Some {
        Some(int: 0)
    }
}

public typealias SomeStub = Some
"""

private let unknownTypeStruct: String = """
@Stubbed
public struct Some {
    let unknown: Unknown
}
"""

private let unknownTypeStructExpansion: String = """
public struct Some {
    let unknown: Unknown

    static var stub: Some {
        Some(unknown: UnknownStub.stub)
    }
}

public typealias SomeStub = Some
"""
#endif
