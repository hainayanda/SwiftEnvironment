//
//  IntegrationTests.swift
//  SwiftEnvironment_Tests
//
//  Created by Nayanda Haberty on 14/3/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftEnvironment
import SwiftUI

final class IntegrationTests: XCTestCase {
    
    override func setUp() {
        EnvironmentValuesResolver.global = EnvironmentValuesResolver()
    }
    
    func test_givenNoInjection_whenGet_shouldReturnDefault() {
        @GlobalEnvironment(\.dummy) var dummy
        XCTAssertTrue(dummy === DummyEnvironmentKey.defaultValue)
    }
    
    func test_givenBasicEnvironmentInjection_whenGet_shouldAlwaysReturnSameValue() {
        GlobalResolver.environment(\.dummy, DummyDependencyStub())
        
        @GlobalEnvironment(\.dummy) var dummy1
        @GlobalEnvironment(\.dummy) var dummy2
        
        XCTAssertFalse(dummy1 === DummyEnvironmentKey.defaultValue)
        XCTAssertTrue(dummy1 === dummy2)
    }
    
    func test_givenTransientInjection_whenGet_shouldAlwaysReturnNewValue() {
        GlobalResolver.transient(\.dummy, DummyDependencyStub())
        
        @GlobalEnvironment(\.dummy) var dummy1
        @GlobalEnvironment(\.dummy) var dummy2
        
        XCTAssertFalse(dummy1 === DummyEnvironmentKey.defaultValue)
        XCTAssertFalse(dummy1 === dummy2)
    }
    
    func test_givenWeakInjection_whenGet_shouldAlwaysReturnSameValue() {
        GlobalResolver.weak(\.dummy, DummyDependencyStub())
        
        @GlobalEnvironment(\.dummy) var dummy1
        @GlobalEnvironment(\.dummy) var dummy2
        
        XCTAssertFalse(dummy1 === DummyEnvironmentKey.defaultValue)
        XCTAssertTrue(dummy1 === dummy2)
    }
    
    func test_givenConnectedInjection_whenGet_shouldAlwaysReturnSameValue() {
        GlobalResolver.environment(\.dummy, DummyDependencyStub())
        GlobalResolver.environment(\.secondDummy, use: \.dummy)
        
        @GlobalEnvironment(\.dummy) var dummy1
        @GlobalEnvironment(\.secondDummy) var dummy2
        
        XCTAssertTrue(dummy1 === dummy2)
    }
    
    func test_givenTwoConnectedInjection_whenGet_shouldAlwaysReturnSameValue() {
        GlobalResolver.environment(\.dummy, DummyDependencyStub())
        GlobalResolver.environment(\.secondDummy, \.thirdDummy, use: \.dummy)
        
        @GlobalEnvironment(\.dummy) var dummy1
        @GlobalEnvironment(\.secondDummy) var dummy2
        @GlobalEnvironment(\.thirdDummy) var dummy3
        
        XCTAssertTrue(dummy1 === dummy2)
        XCTAssertTrue(dummy1 === dummy3)
    }
    
    func test_givenThreeConnectedInjection_whenGet_shouldAlwaysReturnSameValue() {
        GlobalResolver.environment(\.dummy, DummyDependencyStub())
        GlobalResolver.environment(\.secondDummy, \.thirdDummy, \.fourthDummy, use: \.dummy)
        
        @GlobalEnvironment(\.dummy) var dummy1
        @GlobalEnvironment(\.secondDummy) var dummy2
        @GlobalEnvironment(\.thirdDummy) var dummy3
        @GlobalEnvironment(\.fourthDummy) var dummy4
        
        XCTAssertTrue(dummy1 === dummy2)
        XCTAssertTrue(dummy2 === dummy3)
        XCTAssertTrue(dummy3 === dummy4)
    }
    
    func test_givenConnectedInjection_whenGet_shouldReturnDefault() {
        GlobalResolver.environment(\.dummy, DummyDependencyStub())
        GlobalResolver.environment(\.fifthDummy, use: \.dummy)
        
        @GlobalEnvironment(\.fifthDummy) var dummy
        
        XCTAssertEqual(dummy, "dummy")
    }
    
}

typealias DummyEnvironmentKey = EnvironmentValues.DummySwiftEnvironmentKey

@EnvironmentValue
extension EnvironmentValues {
    static let dummy = DummyDependencyStub()
    static let secondDummy = DummyDependencyStub()
    static let thirdDummy = DummyDependencyStub()
    static let fourthDummy = DummyDependencyStub()
    static let fifthDummy: String = "dummy"
}
