# SwiftEnvironment

SwiftEnvironment is a Swift library designed to simplify environment value management in SwiftUI applications. It provides convenient macros and utilities to streamline the process of defining and injecting environment values.

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/9dbed03fc0cd49f8a8fdd97a33edf29b)](https://app.codacy.com/gh/hainayanda/SwiftEnvironment/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen)](https://swift.org/package-manager/)
[![Unit Test](https://github.com/hainayanda/SwiftEnvironment/actions/workflows/test.yml/badge.svg)](https://github.com/hainayanda/SwiftEnvironment/actions/workflows/test.yml)

## Requirements

- Swift 5.10 or higher
- iOS 13.0 or higher
- MacOS 10.15 or higher
- TVOS 13.0 or higher
- WatchOS 6.0 or higher
- Xcode 15 or higher

## Installation

### Swift Package Manager (Xcode)

To install using Xcode's Swift Package Manager, follow these steps:

- Go to **File > Swift Package > Add Package Dependency**
- Enter the URL: **<https://github.com/hainayanda/SwiftEnvironment.git>**
- Choose **Up to Next Major** for the version rule and set the version to **1.0.0**.
- Click "Next" and wait for the package to be fetched.

### Swift Package Manager (Package.swift)

If you prefer using Package.swift, add SwiftEnvironment as a dependency in your **Package.swift** file:

```swift
dependencies: [
    .package(url: "https://github.com/hainayanda/SwiftEnvironment.git", .upToNextMajor(from: "1.0.0"))
]
```

Then, include it in your target:

```swift
 .target(
    name: "MyModule",
    dependencies: ["SwiftEnvironment"]
)
```

## Usage

### EnvironmentValue macro

The `EnvironmentValue` macro is used to remove boilerplate code when adding a new variable to EnvironmentValue. To use it, simply add `@EnvironmentValue("<name of the value KeyPath>")` to the extension of `EnvironmentValues` with the structure of your `EnvironmentKey`.

```swift
import SwiftEnvironment

@EnvironmentValue("myValue")
extension EnvironmentValues {
    struct MyEnvironmentKey: EnvironmentKey {
        static let defaultValue = MyDependency()
    }
}
```

This allows you to use `myValue` as a SwiftUI Environment KeyPath argument:

```swift
@Environment(\.myValue) var myValue
```

or for view injection:

```swift
SomeView()
    .environment(\.myValue, SomeDependency())
```

### GlobalEnvironment

`GlobalEnvironment` complements SwiftUI Environment. It allows `EnvironmentValues` to be accessed globally outside of SwiftUI injection scope. To use it, add EnvironmentValues just like how we add it for SwiftUI, and inject it into `GlobalResolver`:

```swift
GlobalResolver
    .environment(\.myValue, SomeDependency())
```

Then, you can access it globally using `GlobalEnvironment` property wrapper:

```swift
@GlobalEnvironment(\.myValue) var myValue
```

### GlobalResolver environment

Injected values to `GlobalResolver.environment` are injected using `autoclosure`, so the value will be created lazily. This value will be stored as long as the app is alive. You can inject an explicit closure too if needed:

```swift
GlobalResolver
    .environment(\.myValue) { 
        SomeDependency()
    }
```

### GlobalResolver transient

Another injection method for GlobalResolver is `transient`. This method ensures that the value will be newly created when first accessed from GlobalEnvironment property wrapper. To inject, simply call transient from GlobalEnvironment and proceed as usual:

```swift
GlobalResolver
    .transient(\.myValue, SomeDependency())
```

### GlobalResolver weak

Another injection method for GlobalResolver is `weak`. This method ensures that the value will be stored in a weak variable and will be newly created only when the last resolved value is null. To inject, simply call weak from GlobalEnvironment and proceed as usual:

```swift
GlobalResolver
    .weak(\.myValue, SomeDependency())
```

## Contributing

Contributions are welcome! Please follow the guidelines in the [CONTRIBUTING.md](CONTRIBUTING.md) file.

## License

MosaicGrid is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Credits

This project is maintained by [Nayanda Haberty](hainayanda@outlook.com).
