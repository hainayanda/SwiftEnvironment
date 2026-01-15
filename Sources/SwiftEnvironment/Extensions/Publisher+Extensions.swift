//
//  Publisher+Extensions.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 10/03/25.
//

import Foundation
import Combine

extension Publisher where Failure == Never {
    /// Assigns the publisher's output to a property on an object using weak references to prevent retain cycles.
    /// 
    /// - Parameters:
    ///   - keyPath: The key path to the property to assign.
    ///   - object: The object whose property will be updated.
    /// - Returns: An `AnyCancellable` that can be used to cancel the subscription.
    @inlinable func weakAssign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on object: Root) -> AnyCancellable {
        sink { [weak object] output in
            object?[keyPath: keyPath] = output
        }
    }
}
