//
//  InstanceResolver.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 14/3/24.
//

import Foundation
import Chary

// MARK: InstanceResolver

protocol InstanceResolver {
    func resolve<V>(for type: V.Type) -> V?
}

// MARK: StaticInstanceResolver

struct StaticInstanceResolver<Value>: InstanceResolver {
    
    let value: Value
    
    @inlinable func resolve<V>(for type: V.Type) -> V? {
        value as? V
    }
}

// MARK: SingletonInstanceResolver

final class SingletonInstanceResolver<Value>: InstanceResolver {
    
    var instance: Value?
    var resolver: (() -> Value)?
    let queue: DispatchQueue?
    
    @inlinable init(queue: DispatchQueue?, resolver: @escaping () -> Value) {
        self.resolver = resolver
        self.queue = queue
    }
    
    @inlinable func resolve<V>(for type: V.Type) -> V? {
        guard let instance else {
            // this resolver should not be nil in this line
            let resolver = self.resolver!
            let newInstance = queue?.safeSync(execute: resolver) ?? resolver()
            self.resolver = nil
            self.instance = newInstance
            return newInstance as? V
        }
        return instance as? V
    }
}

// MARK: TransientInstanceResolver

struct TransientInstanceResolver<Value>: InstanceResolver {
    
    var resolver: () -> Value
    let queue: DispatchQueue?
    
    @inlinable init(queue: DispatchQueue?, resolver: @escaping () -> Value) {
        self.resolver = resolver
        self.queue = queue
    }
    
    @inlinable func resolve<V>(for type: V.Type) -> V? {
        let instance = queue?.safeSync(execute: resolver) ?? resolver()
        guard let kInstance = instance as? V else {
            return nil
        }
        return kInstance
    }
}

// MARK: WeakInstanceResolver

final class WeakInstanceResolver<Value: AnyObject>: InstanceResolver {
    
    weak var instance: Value?
    var resolver: () -> Value
    let queue: DispatchQueue?
    
    @inlinable init(queue: DispatchQueue?, resolver: @escaping () -> Value) {
        self.resolver = resolver
        self.queue = queue
    }
    
    @inlinable func resolve<V>(for type: V.Type) -> V? {
        guard let instance else {
            let newInstance = queue?.safeSync(execute: resolver) ?? resolver()
            self.instance = newInstance
            return newInstance as? V
        }
        return instance as? V
    }
}
