//
//  File.swift
//
//
//  Created by Nayanda Haberty on 16/3/24.
//

import XCTest
import SwiftSyntaxMacrosTestSupport
@testable import SwiftEnvironmentMacro

// swiftlint:disable file_length
final class StubFromProtocolGeneratorMacroTests: XCTestCase {
    
    func test_givenSimpleProtocol_shouldGenerateDefault() {
        assertMacroExpansion(
            simpleProtocol,
            expandedSource: simpleProtocolExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenOptionalProtocol_shouldGenerateDefault() {
        assertMacroExpansion(
            optionalProtocol,
            expandedSource: optionalProtocolExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenArrayProtocol_shouldGenerateDefault() {
        assertMacroExpansion(
            arrayProtocol,
            expandedSource: arrayProtocolExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenDictionaryProtocol_shouldGenerateDefault() {
        assertMacroExpansion(
            dictionaryProtocol,
            expandedSource: dictionaryProtocolExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenClassProtocol_shouldGenerateDefault() {
        assertMacroExpansion(
            classProtocol,
            expandedSource: classProtocolExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenSuperClassProtocol_shouldGenerateDefault() {
        assertMacroExpansion(
            superClassProtocol,
            expandedSource: superClassProtocolExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenInjectValueProtocol_shouldGenerateDefault() {
        assertMacroExpansion(
            injectValueProtocol,
            expandedSource: injectValueProtocolExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenStructProtocol_shouldGenerateDefault() {
        assertMacroExpansion(
            structProtocol,
            expandedSource: structProtocolExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenAllArgsProtocol_shouldGenerateDefault() {
        assertMacroExpansion(
            allArgsProtocol,
            expandedSource: allArgsProtocolExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
    
    func test_givenAnyObjectProtocol_shouldGenerateDefault() {
        assertMacroExpansion(
            anyObjectProtocol,
            expandedSource: anyObjectProtocolExpansion,
            macros: ["Stubbed": StubGeneratorMacro.self]
        )
    }
}

private let anyObjectProtocol: String = """
@Stubbed(type: .class)
protocol Some: AnyObject {
    var int: Int { get }
}
"""

private let anyObjectProtocolExpansion: String = """
protocol Some: AnyObject {
    var int: Int { get }
}

final class SomeStub: Some {
    let int: Int = 0
    init() {
    }
}
"""

private let allArgsProtocol: String = """
@Stubbed(type: .subclass(Super.self), .value(for: Int.self, 1), .value(for: Unknown.self, Unknown()))
protocol Some {
    var int: Int { get }
    var unknown: Unknown { get }
}
"""

private let allArgsProtocolExpansion: String = """
protocol Some {
    var int: Int { get }
    var unknown: Unknown { get }
}

final class SomeStub: Super, Some {
    let int: Int = 1
    let unknown: Unknown = Unknown()
    init() {
    }
}
"""

private let structProtocol: String = """
@Stubbed(type: .struct)
protocol Some {
    var int: Int { get }
}
"""

private let structProtocolExpansion: String = """
protocol Some {
    var int: Int { get }
}

struct SomeStub: Some {
    let int: Int = 0
    init() {
    }
}
"""

private let injectValueProtocol: String = """
@Stubbed(type: .struct, .value(for: Int.self, 1), .value(for: Unknown.self, Unknown()))
protocol Some {
    var int: Int { get }
    var unknown: Unknown { get }
}
"""

private let injectValueProtocolExpansion: String = """
protocol Some {
    var int: Int { get }
    var unknown: Unknown { get }
}

struct SomeStub: Some {
    let int: Int = 1
    let unknown: Unknown = Unknown()
    init() {
    }
}
"""

private let superClassProtocol: String = """
@Stubbed(type: .subclass(Super.self))
protocol Some {
    var int: Int { get }
}
"""

private let superClassProtocolExpansion: String = """
protocol Some {
    var int: Int { get }
}

final class SomeStub: Super, Some {
    let int: Int = 0
    init() {
    }
}
"""

private let classProtocol: String = """
@Stubbed(type: .class)
protocol Some {
    var int: Int { get }
}
"""

private let classProtocolExpansion: String = """
protocol Some {
    var int: Int { get }
}

final class SomeStub: Some {
    let int: Int = 0
    init() {
    }
}
"""

private let simpleProtocol: String = """
@Stubbed(type: .struct)
protocol Some {
    var int: Int { get }
    var double: Double { get set }
    var bool: Bool { get async }
    var string: String { get async throws }
        
    func voidFunc() -> Void
    func asyncVoidFunc() async
    func asyncThrowsVoidFunc() async throws
        
    func defaultFunc() -> Int
    func asyncDefaultFunc() async -> Double
    func asyncThrowsDefaultFunc() async throws -> String
}
"""

private let simpleProtocolExpansion: String = """
protocol Some {
    var int: Int { get }
    var double: Double { get set }
    var bool: Bool { get async }
    var string: String { get async throws }
        
    func voidFunc() -> Void
    func asyncVoidFunc() async
    func asyncThrowsVoidFunc() async throws
        
    func defaultFunc() -> Int
    func asyncDefaultFunc() async -> Double
    func asyncThrowsDefaultFunc() async throws -> String
}

struct SomeStub: Some {
    let int: Int = 0
    var double: Double = 0.0
    let bool: Bool = false
    let string: String = ""
    init() {
    }
    func voidFunc() -> Void {
    }
    func asyncVoidFunc() async {
    }
    func asyncThrowsVoidFunc() async throws {
    }
    func defaultFunc() -> Int {
        return 0
    }
    func asyncDefaultFunc() async -> Double {
        return 0.0
    }
    func asyncThrowsDefaultFunc() async throws -> String {
        return ""
    }
}
"""

private let optionalProtocol: String = """
@Stubbed(type: .struct)
protocol Some {
    var int: Int? { get }
    var double: Optional<Double> { get set }
    var bool: Bool? { get async }
    var string: String? { get async throws }
    var unknown: Unknown? { get set }
        
    func defaultFunc() -> Int?
    func asyncDefaultFunc() async -> Optional<Double>
    func asyncThrowsDefaultFunc() async throws -> String?
    func unknownDefaultFunc() async throws -> Unknown?
}
"""

private let optionalProtocolExpansion: String = """
protocol Some {
    var int: Int? { get }
    var double: Optional<Double> { get set }
    var bool: Bool? { get async }
    var string: String? { get async throws }
    var unknown: Unknown? { get set }
        
    func defaultFunc() -> Int?
    func asyncDefaultFunc() async -> Optional<Double>
    func asyncThrowsDefaultFunc() async throws -> String?
    func unknownDefaultFunc() async throws -> Unknown?
}

struct SomeStub: Some {
    let int: Int? = nil
    var double: Optional<Double> = nil
    let bool: Bool? = nil
    let string: String? = nil
    var unknown: Unknown? = nil
    init() {
    }
    func defaultFunc() -> Int? {
        return nil
    }
    func asyncDefaultFunc() async -> Optional<Double> {
        return nil
    }
    func asyncThrowsDefaultFunc() async throws -> String? {
        return nil
    }
    func unknownDefaultFunc() async throws -> Unknown? {
        return nil
    }
}
"""

private let arrayProtocol: String = """
@Stubbed(type: .struct)
protocol Some {
    var int: [Int] { get }
    var double: Array<Double> { get set }
    var bool: [Bool] { get async }
    var string: [String] { get async throws }
    var unknown: [Unknown] { get set }
        
    func defaultFunc() -> [Int]
    func asyncDefaultFunc() async -> Array<Double>
    func asyncThrowsDefaultFunc() async throws -> [String]
    func unknownDefaultFunc() async throws -> [Unknown]
}
"""

private let arrayProtocolExpansion: String = """
protocol Some {
    var int: [Int] { get }
    var double: Array<Double> { get set }
    var bool: [Bool] { get async }
    var string: [String] { get async throws }
    var unknown: [Unknown] { get set }
        
    func defaultFunc() -> [Int]
    func asyncDefaultFunc() async -> Array<Double>
    func asyncThrowsDefaultFunc() async throws -> [String]
    func unknownDefaultFunc() async throws -> [Unknown]
}

struct SomeStub: Some {
    let int: [Int] = []
    var double: Array<Double> = []
    let bool: [Bool] = []
    let string: [String] = []
    var unknown: [Unknown] = []
    init() {
    }
    func defaultFunc() -> [Int] {
        return []
    }
    func asyncDefaultFunc() async -> Array<Double> {
        return []
    }
    func asyncThrowsDefaultFunc() async throws -> [String] {
        return []
    }
    func unknownDefaultFunc() async throws -> [Unknown] {
        return []
    }
}
"""

private let dictionaryProtocol: String = """
@Stubbed(type: .struct)
protocol Some {
    var int: [Int: Unknown] { get }
    var double: Dictionary<Double, Unknown?> { get set }
    var bool: [Bool: (Unknown)] { get async }
    var string: [String: Unknown] { get async throws }
    var unknown: [Unknown: Unknown] { get set }
        
    func defaultFunc() -> [Int: Unknown]
    func asyncDefaultFunc() async -> Dictionary<Double, Unknown?>
    func asyncThrowsDefaultFunc() async throws -> [String: Unknown]
    func unknownDefaultFunc() async throws -> [Unknown: Unknown]
}
"""

private let dictionaryProtocolExpansion: String = """
protocol Some {
    var int: [Int: Unknown] { get }
    var double: Dictionary<Double, Unknown?> { get set }
    var bool: [Bool: (Unknown)] { get async }
    var string: [String: Unknown] { get async throws }
    var unknown: [Unknown: Unknown] { get set }
        
    func defaultFunc() -> [Int: Unknown]
    func asyncDefaultFunc() async -> Dictionary<Double, Unknown?>
    func asyncThrowsDefaultFunc() async throws -> [String: Unknown]
    func unknownDefaultFunc() async throws -> [Unknown: Unknown]
}

struct SomeStub: Some {
    let int: [Int: Unknown] = [:]
    var double: Dictionary<Double, Unknown?> = [:]
    let bool: [Bool: (Unknown)] = [:]
    let string: [String: Unknown] = [:]
    var unknown: [Unknown: Unknown] = [:]
    init() {
    }
    func defaultFunc() -> [Int: Unknown] {
        return [:]
    }
    func asyncDefaultFunc() async -> Dictionary<Double, Unknown?> {
        return [:]
    }
    func asyncThrowsDefaultFunc() async throws -> [String: Unknown] {
        return [:]
    }
    func unknownDefaultFunc() async throws -> [Unknown: Unknown] {
        return [:]
    }
}
"""
