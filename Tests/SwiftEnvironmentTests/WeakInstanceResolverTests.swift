//
//  WeakInstanceResolverTests.swift
//  SwiftEnvironment_Tests
//
//  Created by Nayanda Haberty on 14/3/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftEnvironment

final class WeakInstanceResolverTests: XCTestCase {
    
    func test_givenResolver_whenResolve_shouldReturnSameInstance() {
        let resolver = WeakInstanceResolver(queue: nil) { DummyClass() }
        let resolved1 = resolver.resolve(for: DummyDependency.self)
        let resolved2 = resolver.resolve(for: DummyDependency.self)
        XCTAssertNotNil(resolved1)
        XCTAssertNotNil(resolved2)
        XCTAssertTrue(resolved1 === resolved2)
    }
    
    func test_givenValue_whenResolveWrongType_shouldReturnNil() {
        let resolver = WeakInstanceResolver(queue: nil) { DummyClass() }
        let resolved = resolver.resolve(for: String.self)
        XCTAssertNil(resolved)
    }
    
    func test_givenValue_whenResolveAfterReleased_shouldReturnNewInstance() {
        let resolver = WeakInstanceResolver(queue: nil) { DummyClass() }
        var resolved: DummyDependency? = resolver.resolve(for: DummyDependency.self)
        let id1 = resolved!.id
        resolved = nil
        resolved = resolver.resolve(for: DummyDependency.self)
        let id2 = resolved!.id
        XCTAssertNotEqual(id1, id2)
    }
    
    func test_givenQueue_whenResolve_shouldDoItInGivenQueue() async {
        var isMainThread: Bool?
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let resolver = WeakInstanceResolver(queue: .global()) {
                defer {
                    continuation.resume()
                }
                isMainThread = Thread.isMainThread
                return DummyClass()
            }
            _ = resolver.resolve(for: DummyDependency.self)
        }
        XCTAssertNotNil(isMainThread)
        XCTAssertFalse(isMainThread!)
    }

}
