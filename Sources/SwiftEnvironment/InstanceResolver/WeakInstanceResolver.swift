//
//  WeakInstanceResolver.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 5/11/24.
//

import Foundation

final class WeakInstanceResolver<Value>: InstanceResolver {
    let id: UUID = UUID()
    private(set) weak var instance: AnyObject?
    private let resolver: () -> Value
    private let executor: DispatchQueueExecutor?
    
    private let lock: NSLock = NSLock()
    
    init(queue: DispatchQueue?, resolver: @escaping () -> Value) {
        self.resolver = resolver
        self.executor = queue.map(DispatchQueueExecutor.init)
    }
    
    func resolve<V>(for type: V.Type) -> V? {
        lock.lock()
        defer { lock.unlock() }
        
        if let instance = instance {
            return instance as? V
        }
        
        let newInstance = executor?.sync(execute: resolver) ?? resolver()
        let isClassInstance = Swift.type(of: newInstance) is AnyClass
        if !isClassInstance {
            assertionFailure("WeakInstanceResolver expects a class instance. Use a class-bound protocol or ensure the resolver returns a reference type.")
        } else {
            self.instance = newInstance as AnyObject
        }
        return newInstance as? V
    }
}
