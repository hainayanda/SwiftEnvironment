//
//  InstanceResolver.swift
//  SwiftEnvironment_Tests
//
//  Created by Nayanda Haberty on 14/3/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import XCTest
@testable import SwiftEnvironment

final class StaticInstanceResolverTests: XCTestCase {
    
    func test_givenValue_whenResolve_shouldReturnSameInstance() {
        let dependency = DummyDependency()
        let resolver = StaticInstanceResolver(value: dependency)
        let resolved = resolver.resolve(for: DummyDependency.self)
        XCTAssertNotNil(resolved)
        XCTAssertTrue(resolved === dependency)
    }
    
    func test_givenValue_whenResolveWrongType_shouldReturnNil() {
        let dependency = DummyDependency()
        let resolver = StaticInstanceResolver(value: dependency)
        let resolved = resolver.resolve(for: String.self)
        XCTAssertNil(resolved)
    }

}
