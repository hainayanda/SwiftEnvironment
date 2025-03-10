//
//  InstanceResolver.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 14/3/24.
//

import Foundation
import SwiftUI

public protocol InstanceResolver {
    func resolve<V>(for type: V.Type) -> V?
}
