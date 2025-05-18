# SwiftEnvironment

SwiftEnvironment is a Swift library designed to allow global access to SwiftUI EnvironmentValues.

![GitHub Release](https://img.shields.io/github/v/release/hainayanda/swiftenvironment)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/9dbed03fc0cd49f8a8fdd97a33edf29b)](https://app.codacy.com/gh/hainayanda/SwiftEnvironment/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen)](https://swift.org/package-manager/)
[![Unit Test](https://github.com/hainayanda/SwiftEnvironment/actions/workflows/test.yml/badge.svg)](https://github.com/hainayanda/SwiftEnvironment/actions/workflows/test.yml)

## Requirements

- Swift 5.9 or higher
- iOS 15.0 or higher
- MacOS 12.0 or higher
- TVOS 15.0 or higher
- WatchOS 8.0 or higher
- VisionOS 1.0 or higher
- Xcode 15 or higher

## Installation

### Swift Package Manager (Xcode)

To install using Xcode's Swift Package Manager, follow these steps:

- Go to **File > Swift Package > Add Package Dependency**
- Enter the URL: **<https://github.com/hainayanda/SwiftEnvironment.git>**
- Choose **Up to Next Major** for the version rule and set the version to **3.0.1**.
- Click "Next" and wait for the package to be fetched.

### Swift Package Manager (Package.swift)

If you prefer using Package.swift, add SwiftEnvironment as a dependency in your **Package.swift** file:

```swift
dependencies: [
    .package(url: "https://github.com/hainayanda/SwiftEnvironment.git", .upToNextMajor(from: "3.0.1"))
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

This library allows you to utilize `EnvironmentValues` as global managed Environment:

```swift
// provide environment as usual
extension EnvironmentValues {
    @Entry var myValue: SomeDependency = SomeDependency()
}

// assign real dependency so it can be accessed globally
EnvironmentValue.global
    .environment(\.myValue, SomeDependency(id: "real-dependency"))
```

Then you can access the value from anywhere globally:

```swift
@GlobalEnvironment(\.myValue) var myValue
```

or inject it to SwiftUI Environment by using `@EnvironmentSource`:

```swift
@main
struct MyApp: App {
    
    @EnvironmentSource(.global) var source
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultEnvironment(\.myValue, from: source)
    }
}
```

Both `@GlobalEnvironment` and `@EnvironmentSource` will be updated when the value is updated from `EnvironmentValue.global` and if used inside SwiftUI View will trigger SwiftUI render event if needed.

### Transient Environment Values

Another injection method for GlobalResolver is `transient`. This method ensures that the value will be newly created when first accessed from GlobalEnvironment property wrapper. To inject, simply call transient from GlobalEnvironment and proceed as usual:

```swift
EnvironmentValue.global
    .transient(\.myValue, SomeDependency())
```

### Weak Environment Values

Another injection method for GlobalResolver is `weak`. This method ensures that the value will be stored in a weak variable and will be newly created only when the last resolved value is null. To inject, simply call weak from GlobalEnvironment and proceed as usual:

```swift
EnvironmentValue.global
    .weak(\.myValue, SomeDependency())
```

## Contributing

Contributions are welcome! Please follow the guidelines in the [CONTRIBUTING.md](CONTRIBUTING.md) file.

## License

MosaicGrid is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Credits

This project is maintained by [Nayanda Haberty](hainayanda@outlook.com).
