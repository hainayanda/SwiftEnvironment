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

To install using Xcode's Swift Package Manager:

1. Go to **File > Swift Package > Add Package Dependency**
2. Enter the URL: **<https://github.com/hainayanda/SwiftEnvironment.git>**
3. Choose **Up to Next Major** for the version rule and set the version to **4.1.4**
4. Click "Next" and wait for the package to be fetched

### Swift Package Manager (Package.swift)

To add SwiftEnvironment as a dependency in your **Package.swift** file:

```swift
dependencies: [
    .package(url: "https://github.com/hainayanda/SwiftEnvironment.git", .upToNextMajor(from: "4.1.4"))
]
```

Then include it in your target:

```swift
.target(
    name: "MyModule",
    dependencies: ["SwiftEnvironment"]
)
```

## Usage

### Defining Global Values

Define your global values using the `@GlobalEntry` macro:

```swift
extension GlobalValues {
    @GlobalEntry var myValue: SomeDependency = SomeDependency()
}
```

### Accessing Global Values

Access global values directly:

```swift
let value = GlobalValue.myValue
```

Or use property wrappers in SwiftUI views:

```swift
@GlobalEnvironment(\.myValue) var myValue
```

The `@GlobalEnvironment` property wrapper implements `DynamicProperty`, ensuring your view automatically updates whenever the source value changes, similar to SwiftUI's `@Environment`:

```swift
struct MyView: View {
    @GlobalEnvironment(\.myValue) var myValue
    
    var body: some View {
        Text(myValue.description)
    }
}
```

### Setting Global Values

There are several ways to set and manage global values:

#### Basic Setting

Set a value directly:

```swift
GlobalValues.environment(\.myValue, SomeNewValue())
```

#### Transient Values

Create values that are always newly instantiated on access:

```swift
GlobalValues.transient(\.myValue, SomeNewValue())
```

#### Weak References

Create values that can be deallocated when no longer referenced:

```swift
GlobalValues.weak(\.myValue, SomeNewValue())
```

### Advanced Options

#### Using Closures

You can provide a closure for value creation (all value setters use autoclosure under the hood):

```swift
GlobalValues.environment(\.myValue) { 
    SomeNewValue() 
}
```

#### Queue Specification

Specify which DispatchQueue should handle value access:

```swift
GlobalValues.environment(\.myValue, resolveOn: .main, SomeNewValue())
```

Note: Queue specification is available for all value types (environment, transient, and weak).

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

SwiftEnvironment is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Credits

Maintained by [Nayanda Haberty](hainayanda@outlook.com)
