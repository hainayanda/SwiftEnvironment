//
//  IntegrationTests.swift
//  SwiftEnvironment_Tests
//
//  Created by Nayanda Haberty on 14/3/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftEnvironment

final class IntegrationTests: XCTestCase {
    
    override func setUp() {
        GlobalValues.reset()
    }
    
    func test_givenTransientInjection_whenGet_shouldAlwaysReturnNewValue() {
        GlobalValues.transient(\.dummy, DummyClass())
        
        @GlobalEnvironment(\.dummy) var dummy1
        @GlobalEnvironment(\.dummy) var dummy2
        
        XCTAssertFalse(dummy1 === GlobalValues.dummy)
        XCTAssertFalse(dummy1 === dummy2)
    }
    
    func test_givenConnectedInjection_whenGet_shouldAlwaysReturnSameValue() {
        GlobalValues.environment(\.dummy, DummyClass())
        GlobalValues.use(\.dummy, for: \.secondDummy)
        
        @GlobalEnvironment(\.dummy) var dummy1
        @GlobalEnvironment(\.secondDummy) var dummy2
        
        XCTAssertTrue(dummy1 === dummy2)
    }
    
    func test_givenTwoConnectedInjection_whenGet_shouldAlwaysReturnSameValue() {
        GlobalValues.environment(\.dummy, DummyClass())
        GlobalValues.use(\.dummy, for: \.secondDummy, \.thirdDummy)
        
        @GlobalEnvironment(\.dummy) var dummy1
        @GlobalEnvironment(\.secondDummy) var dummy2
        @GlobalEnvironment(\.thirdDummy) var dummy3
        
        XCTAssertTrue(dummy1 === dummy2)
        XCTAssertTrue(dummy1 === dummy3)
    }
    
    func test_givenThreeConnectedInjection_whenGet_shouldAlwaysReturnSameValue() {
        GlobalValues.environment(\.dummy, DummyClass())
        GlobalValues.use(\.dummy, for: \.secondDummy, \.thirdDummy, \.fourthDummy)
        
        @GlobalEnvironment(\.dummy) var dummy1
        @GlobalEnvironment(\.secondDummy) var dummy2
        @GlobalEnvironment(\.thirdDummy) var dummy3
        @GlobalEnvironment(\.fourthDummy) var dummy4
        
        XCTAssertTrue(dummy1 === dummy2)
        XCTAssertTrue(dummy2 === dummy3)
        XCTAssertTrue(dummy3 === dummy4)
    }
    
    func test_givenConnectedInjection_whenGet_shouldReturnDefault() {
        GlobalValues.environment(\.dummy, DummyClass())
        GlobalValues.use(\.dummy, for: \.fifthDummy)
        
        @GlobalEnvironment(\.fifthDummy) var dummy
        
        XCTAssertEqual(dummy, "dummy")
    }
    
}
