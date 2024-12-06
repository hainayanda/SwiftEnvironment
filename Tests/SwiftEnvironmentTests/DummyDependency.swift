//
//  DummyDependency.swift
//  SwiftEnvironment_Tests
//
//  Created by Nayanda Haberty on 14/3/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import SwiftEnvironment

@Stubbed(type: .class)
protocol DummyDependency: AnyObject {
    var id: UUID { get }
}

@Stubbed
struct DummyStruct {
    let id: UUID
}

@Stubbed
struct DummyClass {
    let id: UUID
}

typealias DummyEnvironmentKey = EnvironmentValues.DummySwiftEnvironmentKey

@EnvironmentValue
extension EnvironmentValues {
    static let dummy = DummyDependencyStub()
    static let secondDummy = DummyDependencyStub()
    static let thirdDummy = DummyDependencyStub()
    static let fourthDummy = DummyDependencyStub()
    static let fifthDummy: String = "dummy"
}
