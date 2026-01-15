//
//  SingletonInstanceResolver.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 5/11/24.
//

import Foundation

final class SingletonInstanceResolver<Value>: InstanceResolver {
    let id: UUID = UUID()
    private(set) var instance: Value?
    private var resolver: (() -> Value)?
    private let queue: DispatchQueue?
    
    private let lock: NSLock = NSLock()
    
    @inlinable init(queue: DispatchQueue?, resolver: @escaping () -> Value) {
        self.resolver = resolver
        self.queue = queue
    }
    
    @inlinable func resolve<V>(for type: V.Type) -> V? {
        lock.lock()
        defer { lock.unlock() }
        guard let instance else {
            guard let resolver = self.resolver else {
                assertionFailure("SingletonInstanceResolver: resolver is nil before instance was created")
                return nil
            }
            let newInstance = queue?.safeSync(execute: resolver) ?? resolver()
            self.resolver = nil
            self.instance = newInstance
            return newInstance as? V
        }
        return instance as? V
    }
}
