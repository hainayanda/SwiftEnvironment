//
//  SingletonInstanceResolver.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 5/11/24.
//

import Foundation
import SwiftUI

final class SingletonInstanceResolver<Value>: InstanceResolver {
    
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
    
    func assign(to view: any View, for keyPath: AnyKeyPath) -> any View {
        guard let writableKeyPath = keyPath as? WritableKeyPath<EnvironmentValues, Value>,
              let value = resolve(for: Value.self) else {
            return view
        }
        return view.environment(writableKeyPath, value)
    }
}
