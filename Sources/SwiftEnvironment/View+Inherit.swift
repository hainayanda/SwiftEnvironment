//
//  View+Inherit.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 6/11/24.
//

#if canImport(UIKit)
import UIKit
import SwiftUI
import Combine

extension View {
    func inheritEnvironment(from responder: UIResponder) -> any View {
        if #available(iOS 14.0, *) {
            return InheritedEnvironmentView(
                state: InheritedEnvironmentViewState(responder: responder),
                inheritedView: self
            )
        } else {
            let resolvers = (responder.environmentValuesResolver as? EnvironmentValuesRepository)?.resolvers ?? [:]
            return resolvers.reduce(self) { view, pair in
                pair.value.assign(to: view, for: pair.key)
            }
        }
    }
}

@available(iOS 14.0, *)
private struct InheritedEnvironmentView: View {
    @StateObject var state: InheritedEnvironmentViewState
    
    private let inheritedView: AnyView
    
    var body: some View {
        state.resolvers.reduce(inheritedView) { view, pair in
            AnyView(pair.value.assign(to: view, for: pair.key))
        }
    }
    
    init(state: InheritedEnvironmentViewState, inheritedView: any View) {
        self._state = StateObject(wrappedValue: state)
        self.inheritedView = AnyView(inheritedView)
    }
}

private final class InheritedEnvironmentViewState: ObservableObject {
    private weak var responder: UIResponder?
    @Published private(set) var resolvers: [AnyKeyPath: InstanceResolver]
    
    private var resolverCancellable: AnyCancellable?
    
    init(responder: UIResponder) {
        self.responder = responder
        self.resolvers = (responder.environmentValuesResolver as? EnvironmentValuesRepository)?.resolvers ?? [:]
        resolverCancellable  = responder.resolversPublisher
            .weakAssign(to: \.resolvers, on: self)
    }
}
#endif
