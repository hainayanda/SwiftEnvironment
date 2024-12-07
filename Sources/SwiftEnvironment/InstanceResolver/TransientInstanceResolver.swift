//
//  TransientInstanceResolver.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 5/11/24.
//

import Foundation
import Chary
import SwiftUI

struct TransientInstanceResolver<Value>: InstanceResolver {
    
    private let resolver: () -> Value
    private let queue: DispatchQueue?
    
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
    
    @inlinable func assign(to view: any View, for keyPath: AnyKeyPath) -> any View {
        guard let writableKeyPath = keyPath as? WritableKeyPath<EnvironmentValues, Value>,
              let value = resolve(for: Value.self) else {
            return view
        }
        return view.environment(writableKeyPath, value)
    }
}
