//
//  WeakInstanceResolver.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 5/11/24.
//

import Foundation
import Chary
import SwiftUI

final class WeakInstanceResolver<Value: AnyObject>: InstanceResolver {
    
    private(set) weak var instance: Value?
    private let resolver: () -> Value
    private let queue: DispatchQueue?
    
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
    
    func assign(to view: any View, for keyPath: AnyKeyPath) -> any View {
        guard let writableKeyPath = keyPath as? WritableKeyPath<EnvironmentValues, Value>,
              let value = resolve(for: Value.self) else {
            return view
        }
        return view.environment(writableKeyPath, value)
    }
}
