//
//  DummyDependency.swift
//  SwiftEnvironment_Tests
//
//  Created by Nayanda Haberty on 14/3/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import SwiftEnvironment

protocol DummyDependency: AnyObject {
    var id: UUID { get }
}

class DummyClass: DummyDependency {
    let id: UUID = UUID()
}

extension GlobalValues {
    @GlobalEntry var dummy: DummyDependency = DummyClass()
    @GlobalEntry var secondDummy: DummyDependency = DummyClass()
    @GlobalEntry var thirdDummy: DummyDependency = DummyClass()
    @GlobalEntry var fourthDummy: DummyDependency = DummyClass()
    @GlobalEntry var fifthDummy: String = "dummy"
}
