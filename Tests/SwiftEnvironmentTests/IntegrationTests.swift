//
//  IntegrationTests.swift
//  SwiftEnvironment_Tests
//
//  Created by Nayanda Haberty on 14/3/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XCTest
import Combine
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
    
    func test_givenSendableInjection_whenGet_shouldAlwaysReturnNewValue() {
        GlobalValues.transient(\.sixthDummy, DummySendableClass())
        
        @GlobalEnvironment(\.sixthDummy) var dummy1
        @GlobalEnvironment(\.sixthDummy) var dummy2
        
        XCTAssertFalse(dummy1.id == dummy2.id)
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

    func test_givenActiveObserver_whenRegisteringResolverThatReadsAnotherValue_shouldNotDeadlock() {
        // given: a base value, plus an active observer of the value we are about to register.
        // The observer makes assignment eagerly resolve the new value during registration.
        GlobalValues.environment(\.dummy, DummyClass())
        @GlobalEnvironment(\.secondDummy) var observer

        // when: the resolver reads another GlobalValues entry while being constructed, i.e.
        // resolution reentrantly accesses the registry on the same thread.
        let finished = expectation(description: "registration completes without deadlock")
        DispatchQueue.global().async {
            GlobalValues.environment(\.secondDummy) {
                _ = GlobalValues.dummy
                return DummyClass()
            }
            finished.fulfill()
        }

        // then: it must not deadlock (previously a barrier write nesting a read deadlocked).
        wait(for: [finished], timeout: 5)
        XCTAssertNotNil(observer)
    }

    func test_givenResolveQueue_whenResolverReadsAnotherValue_shouldNotDeadlock() {
        GlobalValues.environment(\.dummy, DummyClass())
        GlobalValues.environment(\.secondDummy, resolveOn: DispatchQueue(label: "resolver.queue")) {
            _ = GlobalValues.dummy
            return DummyClass()
        }

        let finished = expectation(description: "queued resolution completes without deadlock")
        DispatchQueue.global().async {
            _ = GlobalValues.secondDummy
            finished.fulfill()
        }

        wait(for: [finished], timeout: 5)
    }

    func test_givenStaleAssignmentEvent_whenPublishingValue_shouldIgnoreStaleResolver() {
        let newerValue = DummyClass()
        let staleValue = DummyClass()
        var receivedValues: [DummyDependency] = []
        let cancellable = GlobalValues.publisher(for: \.dummy)
            .sink { receivedValues.append($0) }

        GlobalValues.environment(\.dummy, newerValue)
        GlobalValues.assignedResolversSubject.send(
            GlobalValuesAssignment(
                keyPath: \.dummy,
                resolver: SingletonInstanceResolver(queue: nil) { staleValue },
                revision: 0
            )
        )

        XCTAssertEqual(receivedValues.count, 1)
        XCTAssertTrue(receivedValues.first === newerValue)
        withExtendedLifetime(cancellable) {}
    }
}
