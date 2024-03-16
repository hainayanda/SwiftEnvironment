//
//  File.swift
//
//
//  Created by Nayanda Haberty on 16/3/24.
//

import XCTest
import SwiftSyntaxMacrosTestSupport
@testable import SwiftEnvironmentMacro

final class StubGeneratorMacroTests: XCTestCase {
    
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
    
    func test_givenNamedProtocol_shouldGenerateDefault() {
        assertMacroExpansion(
            namedProtocol,
            expandedSource: namedProtocolExpansion,
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
        @Stubbed
        public protocol Some: AnyObject {
            var int: Int { get }
        }
        """

private let anyObjectProtocolExpansion: String = """
        public protocol Some: AnyObject {
            var int: Int { get }
        }
        
        public final class SomeStub: Some {
            public let int: Int = 0
            public init() {
            }
        }
        """

private let allArgsProtocol: String = """
        @Stubbed(name: "SomeName", type: .subclass(Super.self), .value(for: Int.self, 1), .value(for: Unknown.self, Unknown()))
        public protocol Some {
            var int: Int { get }
            var unknown: Unknown { get }
        }
        """

private let allArgsProtocolExpansion: String = """
        public protocol Some {
            var int: Int { get }
            var unknown: Unknown { get }
        }
        
        public final class SomeNameStub: Super, Some {
            public let int: Int = 1
            public let unknown: Unknown = Unknown()
            public init() {
            }
        }
        """

private let structProtocol: String = """
        @Stubbed(type: .struct)
        public protocol Some {
            var int: Int { get }
        }
        """

private let structProtocolExpansion: String = """
        public protocol Some {
            var int: Int { get }
        }
        
        public struct SomeStub: Some {
            public let int: Int = 0
            public init() {
            }
        }
        """

private let injectValueProtocol: String = """
        @Stubbed(.value(for: Int.self, 1), .value(for: Unknown.self, Unknown()))
        public protocol Some {
            var int: Int { get }
            var unknown: Unknown { get }
        }
        """

private let injectValueProtocolExpansion: String = """
        public protocol Some {
            var int: Int { get }
            var unknown: Unknown { get }
        }
        
        public struct SomeStub: Some {
            public let int: Int = 1
            public let unknown: Unknown = Unknown()
            public init() {
            }
        }
        """

private let superClassProtocol: String = """
        @Stubbed(type: .subclass(Super.self))
        public protocol Some {
            var int: Int { get }
        }
        """

private let superClassProtocolExpansion: String = """
        public protocol Some {
            var int: Int { get }
        }
        
        public final class SomeStub: Super, Some {
            public let int: Int = 0
            public init() {
            }
        }
        """

private let classProtocol: String = """
        @Stubbed(type: .class)
        public protocol Some {
            var int: Int { get }
        }
        """

private let classProtocolExpansion: String = """
        public protocol Some {
            var int: Int { get }
        }
        
        public final class SomeStub: Some {
            public let int: Int = 0
            public init() {
            }
        }
        """

private let namedProtocol: String = """
        @Stubbed(name: "SomeName")
        public protocol Some {
            var int: Int { get }
        }
        """

private let namedProtocolExpansion: String = """
        public protocol Some {
            var int: Int { get }
        }
        
        public struct SomeNameStub: Some {
            public let int: Int = 0
            public init() {
            }
        }
        """

private let simpleProtocol: String = """
        @Stubbed
        public protocol Some {
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
        public protocol Some {
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
        
        public struct SomeStub: Some {
            public let int: Int = 0
            public var double: Double = 0.0
            public let bool: Bool = false
            public let string: String = ""
            public init() {
            }
            public func voidFunc() -> Void {
                return
            }
            public func asyncVoidFunc() async {
                return
            }
            public func asyncThrowsVoidFunc() async throws {
                return
            }
            public func defaultFunc() -> Int {
                return 0
            }
            public func asyncDefaultFunc() async -> Double {
                return 0.0
            }
            public func asyncThrowsDefaultFunc() async throws -> String {
                return ""
            }
        }
        """

private let optionalProtocol: String = """
        @Stubbed
        public protocol Some {
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
        public protocol Some {
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
        
        public struct SomeStub: Some {
            public let int: Int? = nil
            public var double: Optional<Double> = nil
            public let bool: Bool? = nil
            public let string: String? = nil
            public var unknown: Unknown? = nil
            public init() {
            }
            public func defaultFunc() -> Int? {
                return nil
            }
            public func asyncDefaultFunc() async -> Optional<Double> {
                return nil
            }
            public func asyncThrowsDefaultFunc() async throws -> String? {
                return nil
            }
            public func unknownDefaultFunc() async throws -> Unknown? {
                return nil
            }
        }
        """

private let arrayProtocol: String = """
        @Stubbed
        public protocol Some {
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
        public protocol Some {
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
        
        public struct SomeStub: Some {
            public let int: [Int] = []
            public var double: Array<Double> = []
            public let bool: [Bool] = []
            public let string: [String] = []
            public var unknown: [Unknown] = []
            public init() {
            }
            public func defaultFunc() -> [Int] {
                return []
            }
            public func asyncDefaultFunc() async -> Array<Double> {
                return []
            }
            public func asyncThrowsDefaultFunc() async throws -> [String] {
                return []
            }
            public func unknownDefaultFunc() async throws -> [Unknown] {
                return []
            }
        }
        """

private let dictionaryProtocol: String = """
        @Stubbed
        public protocol Some {
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
        public protocol Some {
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

        public struct SomeStub: Some {
            public let int: [Int: Unknown] = [:]
            public var double: Dictionary<Double, Unknown?> = [:]
            public let bool: [Bool: (Unknown)] = [:]
            public let string: [String: Unknown] = [:]
            public var unknown: [Unknown: Unknown] = [:]
            public init() {
            }
            public func defaultFunc() -> [Int: Unknown] {
                return [:]
            }
            public func asyncDefaultFunc() async -> Dictionary<Double, Unknown?> {
                return [:]
            }
            public func asyncThrowsDefaultFunc() async throws -> [String: Unknown] {
                return [:]
            }
            public func unknownDefaultFunc() async throws -> [Unknown: Unknown] {
                return [:]
            }
        }
        """
