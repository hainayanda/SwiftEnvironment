//
//  SingletonInstanceResolverTests.swift
//  SwiftEnvironment_Tests
//
//  Created by Nayanda Haberty on 14/3/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftEnvironment

final class SingletonInstanceResolverTests: XCTestCase {
    
    func test_givenResolver_whenResolve_shouldReturnSameInstance() {
        let resolver = SingletonInstanceResolver(queue: nil) { DummyDependency() }
        let resolved1 = resolver.resolve(for: DummyDependency.self)
        let resolved2 = resolver.resolve(for: DummyDependency.self)
        XCTAssertNotNil(resolved1)
        XCTAssertNotNil(resolved2)
        XCTAssertTrue(resolved1 === resolved2)
    }
    
    func test_givenValue_whenResolveWrongType_shouldReturnNil() {
        let resolver = SingletonInstanceResolver(queue: nil) { DummyDependency() }
        let resolved = resolver.resolve(for: String.self)
        XCTAssertNil(resolved)
    }
    
    func test_givenQueue_whenResolve_shouldDoItInGivenQueue() async {
        var isMainThread: Bool?
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let resolver = SingletonInstanceResolver(queue: .global()) {
                defer {
                    continuation.resume()
                }
                isMainThread = Thread.isMainThread
                return DummyDependency()
            }
            _ = resolver.resolve(for: DummyDependency.self)
        }
        XCTAssertNotNil(isMainThread)
        XCTAssertFalse(isMainThread!)
    }

}
