//
//  WeakInstanceResolver.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 5/11/24.
//

import Foundation
import Chary
import SwiftUI

final class WeakInstanceResolver<Value>: InstanceResolver {
    let id: UUID = UUID()
    private(set) weak var instance: AnyObject?
    private let resolver: () -> Value
    private let queue: DispatchQueue?
    
    @inlinable init(queue: DispatchQueue?, resolver: @escaping () -> Value) {
        self.resolver = resolver
        self.queue = queue
    }
    
    @inlinable func resolve<V>(for type: V.Type) -> V? {
        guard let instance else {
            let newInstance = queue?.safeSync(execute: resolver) ?? resolver()
            self.instance = newInstance as AnyObject
            return newInstance as? V
        }
        return instance as? V
    }
}
