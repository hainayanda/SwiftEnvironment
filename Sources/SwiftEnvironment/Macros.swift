//
//  Macros.swift
//  SwiftEnvironment
//
//  Created by Nayanda Haberty on 31/05/25.
//

import Foundation

/// A macro that generates a computed property with a default value for use in `GlobalValues` extensions.
///
/// The `@GlobalEntry` macro creates:
/// 1. A computed property that returns either the injected value or the default value
/// 2. A private static constant holding the default value
/// 3. A private nested struct that wraps the default value
///
/// Example:
/// ```swift
/// extension GlobalValues {
///     @GlobalEntry var myService: MyService = MyService()
/// }
/// ```
@attached(accessor)
@attached(peer, names: prefixed(___), prefixed(___ValueWrapper_))
public macro GlobalEntry() = #externalMacro(
    module: "SwiftEnvironmentMacro", type: "GlobalEntryMacro"
)
