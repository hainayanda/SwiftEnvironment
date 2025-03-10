//
//  Publisher+Extensions.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 10/03/25.
//

import Foundation
import Combine

extension Publisher where Failure == Never {
    @inlinable func weakAssign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on object: Root) -> AnyCancellable {
        sink { [weak object] output in
            object?[keyPath: keyPath] = output
        }
    }
}
