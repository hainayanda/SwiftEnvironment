//
//  InstanceResolver.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 14/3/24.
//

import Foundation

/// A protocol that defines how to resolve instances of values.
/// 
/// Instance resolvers are responsible for creating and managing instances of values
/// that can be accessed through `GlobalValues`.
public protocol InstanceResolver {
    /// A unique identifier for the resolver.
    /// 
    /// This is used to track changes and updates to the resolver.
    var id: UUID { get }
    
    /// Resolves an instance of the given type.
    /// 
    /// - Parameter type: The type to resolve.
    /// - Returns: An instance of the type, or `nil` if the type doesn't match.
    func resolve<V>(for type: V.Type) -> V?
}
