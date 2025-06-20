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
