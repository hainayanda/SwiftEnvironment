//
//  WeakInstanceResolver.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 5/11/24.
//

import Foundation
import Chary

final class WeakInstanceResolver<Value>: InstanceResolver {
    let id: UUID = UUID()
    private(set) weak var instance: AnyObject?
    private let resolver: () -> Value
    private let queue: DispatchQueue?
    
    private let lock: NSLock = NSLock()
    
    @inlinable init(queue: DispatchQueue?, resolver: @escaping () -> Value) {
        self.resolver = resolver
        self.queue = queue
    }
    
    @inlinable func resolve<V>(for type: V.Type) -> V? {
        lock.lock()
        defer { lock.unlock() }
        
        if let instance = instance {
            return instance as? V
        }
        
        let newInstance = queue?.safeSync(execute: resolver) ?? resolver()
        let isClassInstance = Swift.type(of: newInstance) is AnyClass
        if !isClassInstance {
            assertionFailure("WeakInstanceResolver expects a class instance. Use a class-bound protocol or ensure the resolver returns a reference type.")
        } else {
            self.instance = newInstance as AnyObject
        }
        return newInstance as? V
    }
}
