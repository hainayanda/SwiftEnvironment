//
//  UIResponder+EnvironmentValuesResolverHost.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 5/11/24.
//

#if canImport(UIKit)
import Foundation
import UIKit
import Combine

private var underlyingResolverKey: Void = ()

extension UIResponder: EnvironmentValuesResolverHost {
    
    @usableFromInline var environmentValuesResolver: EnvironmentValuesResolving {
        guard let currentEnv = underlyingResolver else {
            let newEnv = InheritEnvironmentValuesResolver { [weak self] in
                self?.next?.environmentValuesResolver
            }
            underlyingResolver = newEnv
            return newEnv
        }
        return currentEnv
    }
    
    private var underlyingResolver: EnvironmentValuesResolving? {
        get {
            objc_getAssociatedObject(self, &underlyingResolverKey) as? EnvironmentValuesResolving
        }
        set {
            objc_setAssociatedObject(self, &underlyingResolverKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public var resolversPublisher: AnyPublisher<[AnyKeyPath: InstanceResolver], Never> {
        environmentValuesResolver.resolversPublisher
    }
    
    @inlinable public func environmentValuePublisher<V>(for keyPath: KeyPath<EnvironmentValues, V>) -> AnyPublisher<V, Never> {
        environmentValuesResolver.environmentValuePublisher(for: keyPath)
    }
}
#endif
