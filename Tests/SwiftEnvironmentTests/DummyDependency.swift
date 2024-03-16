//
//  DummyDependency.swift
//  SwiftEnvironment_Tests
//
//  Created by Nayanda Haberty on 14/3/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import SwiftEnvironment

@Stubbed
protocol DummyDependency: AnyObject {
    var id: UUID { get }
}
