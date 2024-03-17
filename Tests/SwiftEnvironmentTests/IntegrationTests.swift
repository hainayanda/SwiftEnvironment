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
    
    func test_givenConnectedInjection_whenGet_shouldReturnDefault() {
        GlobalResolver.environment(\.dummy, DummyDependencyStub())
        GlobalResolver.environment(\.fifthDummy, use: \.dummy)
        
        @GlobalEnvironment(\.fifthDummy) var dummy
        
        XCTAssertEqual(dummy, "dummy")
    }
    
}

typealias DummyEnvironmentKey = EnvironmentValues.DummyEnvironmentKey

@EnvironmentValue("dummy", "secondDummy", "thirdDummy", "fourthDummy", "fifthDummy")
extension EnvironmentValues {
    struct DummyEnvironmentKey: EnvironmentKey {
        static let defaultValue = DummyDependencyStub()
    }
    
    struct SecondDummyEnvironmentKey: EnvironmentKey {
        static let defaultValue = DummyDependencyStub()
    }
    
    struct ThirdDummyEnvironmentKey: EnvironmentKey {
        static let defaultValue = DummyDependencyStub()
    }
    
    struct FourthDummyEnvironmentKey: EnvironmentKey {
        static let defaultValue = DummyDependencyStub()
    }
    
    struct FiftDummyEnvironmentKey: EnvironmentKey {
        static let defaultValue: String = "dummy"
    }
}
