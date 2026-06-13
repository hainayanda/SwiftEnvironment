//
//  DispatchQueueExecutorTests.swift
//  SwiftEnvironmentTests
//

import XCTest
@testable import SwiftEnvironment

final class DispatchQueueExecutorTests: XCTestCase {

    func test_givenCurrentQueue_whenSync_shouldExecuteWithoutDeadlock() {
        let queue = DispatchQueue(label: "DispatchQueueExecutorTests.serialQueue")
        let executor = DispatchQueueExecutor(queue)
        let completed = expectation(description: "Nested sync completed")

        queue.async {
            let value = executor.sync { "resolved" }
            XCTAssertEqual(value, "resolved")
            completed.fulfill()
        }

        wait(for: [completed], timeout: 1)
    }
}
