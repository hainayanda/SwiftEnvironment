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
        EnvironmentValues.global = GlobalEnvironmentValues()
    }
    
    func test_givenTransientInjection_whenGet_shouldAlwaysReturnNewValue() {
        EnvironmentValues.global.transient(\.dummy, DummyClass())
        
        @GlobalEnvironment(\.dummy) var dummy1
        @GlobalEnvironment(\.dummy) var dummy2
        
        XCTAssertFalse(dummy1 === EnvironmentValues.global.dummy)
        XCTAssertFalse(dummy1 === dummy2)
    }
    
    func test_givenConnectedInjection_whenGet_shouldAlwaysReturnSameValue() {
        EnvironmentValues.global.environment(\.dummy, DummyClass())
        EnvironmentValues.global.environment(\.secondDummy, use: \.dummy)
        
        @GlobalEnvironment(\.dummy) var dummy1
        @GlobalEnvironment(\.secondDummy) var dummy2
        
        XCTAssertTrue(dummy1 === dummy2)
    }
    
    func test_givenTwoConnectedInjection_whenGet_shouldAlwaysReturnSameValue() {
        EnvironmentValues.global.environment(\.dummy, DummyClass())
        EnvironmentValues.global.environment(\.secondDummy, \.thirdDummy, use: \.dummy)
        
        @GlobalEnvironment(\.dummy) var dummy1
        @GlobalEnvironment(\.secondDummy) var dummy2
        @GlobalEnvironment(\.thirdDummy) var dummy3
        
        XCTAssertTrue(dummy1 === dummy2)
        XCTAssertTrue(dummy1 === dummy3)
    }
    
    func test_givenThreeConnectedInjection_whenGet_shouldAlwaysReturnSameValue() {
        EnvironmentValues.global.environment(\.dummy, DummyClass())
        EnvironmentValues.global.environment(\.secondDummy, \.thirdDummy, \.fourthDummy, use: \.dummy)
        
        @GlobalEnvironment(\.dummy) var dummy1
        @GlobalEnvironment(\.secondDummy) var dummy2
        @GlobalEnvironment(\.thirdDummy) var dummy3
        @GlobalEnvironment(\.fourthDummy) var dummy4
        
        XCTAssertTrue(dummy1 === dummy2)
        XCTAssertTrue(dummy2 === dummy3)
        XCTAssertTrue(dummy3 === dummy4)
    }
    
    func test_givenConnectedInjection_whenGet_shouldReturnDefault() {
        EnvironmentValues.global.environment(\.dummy, DummyClass())
        EnvironmentValues.global.environment(\.fifthDummy, use: \.dummy)
        
        @GlobalEnvironment(\.fifthDummy) var dummy
        
        XCTAssertEqual(dummy, "dummy")
    }
    
}
