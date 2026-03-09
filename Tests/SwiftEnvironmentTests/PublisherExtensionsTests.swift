//
//  PublisherExtensionsTests.swift
//  SwiftEnvironmentTests
//
//  Created by Nayanda Haberty on 10/03/26.
//

import XCTest
import Combine
@testable import SwiftEnvironment

final class PublisherExtensionsTests: XCTestCase {

    func test_givenMainThreadPublisher_whenEnsureOnMain_thenShouldReceiveOnMainThread() {
        let expectation = expectation(description: "receive on main thread")
        var isMainThread = false
        var cancellables: Set<AnyCancellable> = []

        Just(1)
            .ensureOnMain()
            .sink { value in
                XCTAssertEqual(value, 1)
                isMainThread = Thread.isMainThread
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(isMainThread)
    }

    func test_givenBackgroundThreadPublisher_whenEnsureOnMain_thenShouldReceiveOnMainThread() {
        let expectation = expectation(description: "receive on main thread from background")
        var isMainThread = false
        var cancellables: Set<AnyCancellable> = []

        DispatchQueue.global().async {
            Just(1)
                .ensureOnMain()
                .sink { value in
                    XCTAssertEqual(value, 1)
                    isMainThread = Thread.isMainThread
                    expectation.fulfill()
                }
                .store(in: &cancellables)
        }

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(isMainThread)
    }
}
