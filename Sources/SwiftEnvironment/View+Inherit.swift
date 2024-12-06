//
//  View+Inherit.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 6/11/24.
//

#if canImport(UIKit)
import UIKit
import SwiftUI

extension View {
    func inheritEnvironment(from responder: UIResponder) -> any View {
        let resolvers = (responder.environmentValuesResolver as? EnvironmentValuesRepository)?.resolvers ?? [:]
        return resolvers.reduce(self) { view, pair in
            pair.value.assign(to: view, for: pair.key)
        }
    }
}
#endif
