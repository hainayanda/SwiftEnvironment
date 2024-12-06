//
//  UIKitEnvironmentTests.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 6/12/24.
//

import XCTest
@testable import SwiftEnvironment
import SwiftUI

final class UIKitEnvironmentTests: XCTestCase {
    
    private var window: UIWindow!
    private var viewControllerUnderTest: ViewControllerUnderTest!
    
    override func setUp() {
        window = UIWindow()
        viewControllerUnderTest = ViewControllerUnderTest()
        window.rootViewController = viewControllerUnderTest
        window.makeKeyAndVisible()
    }
    
    func test_givenNoInjection_whenGet_shouldReturnDefault() {
        let dummy1 = viewControllerUnderTest.dummy
        let dummy2 = viewControllerUnderTest.viewUnderTest.dummy
        let dummy3 = viewControllerUnderTest.subViewUnderTest.dummy
        XCTAssertTrue(dummy1 === DummyEnvironmentKey.defaultValue)
        XCTAssertTrue(dummy2 === DummyEnvironmentKey.defaultValue)
        XCTAssertTrue(dummy3 === DummyEnvironmentKey.defaultValue)
    }
    
    func test_givenWindowInjection_whenGet_shouldAlwaysReturnSameValue() {
        window.environment(\.dummy, DummyDependencyStub())
        let dummy1 = viewControllerUnderTest.dummy
        let dummy2 = viewControllerUnderTest.viewUnderTest.dummy
        let dummy3 = viewControllerUnderTest.subViewUnderTest.dummy
        
        XCTAssertFalse(dummy1 === DummyEnvironmentKey.defaultValue)
        XCTAssertTrue(dummy1 === dummy2)
        XCTAssertTrue(dummy2 === dummy3)
    }
    
    func test_givenViewControllerInjection_whenGet_shouldAlwaysReturnSameValue() {
        viewControllerUnderTest.environment(\.dummy, DummyDependencyStub())
        let dummy1 = viewControllerUnderTest.dummy
        let dummy2 = viewControllerUnderTest.viewUnderTest.dummy
        let dummy3 = viewControllerUnderTest.subViewUnderTest.dummy
        
        XCTAssertFalse(dummy1 === DummyEnvironmentKey.defaultValue)
        XCTAssertTrue(dummy1 === dummy2)
        XCTAssertTrue(dummy2 === dummy3)
    }
    
    func test_givenViewInjection_whenGet_shouldNotOverridenByViewControllerValue() {
        viewControllerUnderTest.viewUnderTest.environment(\.dummy, DummyDependencyStub())
        let dummy1 = viewControllerUnderTest.dummy
        let dummy2 = viewControllerUnderTest.viewUnderTest.dummy
        let dummy3 = viewControllerUnderTest.subViewUnderTest.dummy
        
        XCTAssertTrue(dummy1 === DummyEnvironmentKey.defaultValue)
        XCTAssertFalse(dummy2 === DummyEnvironmentKey.defaultValue)
        XCTAssertTrue(dummy2 === dummy3)
    }
    
}

private final class ViewControllerUnderTest: UIViewController {
    @UIEnvironment(\.dummy) var dummy: DummyDependencyStub
    
    lazy var viewUnderTest: ViewUnderTest = {
        let view = ViewUnderTest()
        self.view.addSubview(view)
        return view
    }()
    
    lazy var subViewUnderTest: ViewUnderTest = {
        let view = ViewUnderTest()
        self.viewUnderTest.addSubview(view)
        return view
    }()
}

private final class ViewUnderTest: UIView {
    @UIEnvironment(\.dummy) var dummy: DummyDependencyStub
}
