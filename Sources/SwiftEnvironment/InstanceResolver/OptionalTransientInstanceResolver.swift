//
//  OptionalTransientInstanceResolver.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 01/06/25.
//

import Foundation

struct OptionalTransientInstanceResolver<Value>: InstanceResolver {
    let id: UUID = UUID()
    private let resolver: () -> Value?
    private let executor: DispatchQueueExecutor?
    
    init(queue: DispatchQueue?, resolver: @escaping () -> Value?) {
        self.resolver = resolver
        self.executor = queue.map(DispatchQueueExecutor.init)
    }
    
    func resolve<V>(for type: V.Type) -> V? {
        let instance = executor?.sync(execute: resolver) ?? resolver()
        return instance as? V
    }
}
