//
//  OptionalTransientInstanceResolver.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 01/06/25.
//

import Foundation
import Chary

struct OptionalTransientInstanceResolver<Value>: InstanceResolver {
    let id: UUID = UUID()
    private let resolver: () -> Value?
    private let queue: DispatchQueue?
    
    @inlinable init(queue: DispatchQueue?, resolver: @escaping () -> Value?) {
        self.resolver = resolver
        self.queue = queue
    }
    
    @inlinable func resolve<V>(for type: V.Type) -> V? {
        let instance = queue?.safeSync(execute: resolver) ?? resolver()
        return instance as? V
    }
}
