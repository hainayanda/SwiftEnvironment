//
//  DummyDependency.swift
//  SwiftEnvironment_Tests
//
//  Created by Nayanda Haberty on 14/3/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import SwiftEnvironment
import SwiftUI

protocol DummyDependency: AnyObject {
    var id: UUID { get }
}

class DummyClass: DummyDependency {
    let id: UUID = UUID()
}

extension EnvironmentValues {
    @Entry var dummy: DummyDependency = DummyClass()
    @Entry var secondDummy: DummyDependency = DummyClass()
    @Entry var thirdDummy: DummyDependency = DummyClass()
    @Entry var fourthDummy: DummyDependency = DummyClass()
    @Entry var fifthDummy: String = "dummy"
}
