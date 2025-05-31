// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

// Set this to true to enable swiftlint plugin
var development: Bool = false

let dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/hainayanda/Chary.git", .upToNextMajor(from: "1.0.7")),
    .package(url: "https://github.com/swiftlang/swift-syntax.git", "509.0.0"..<"601.0.0")
]
let pluginsDependencie: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.58.2")
]
let packageDependencies: [PackageDescription.Package.Dependency] = development ? dependencies + pluginsDependencie : dependencies

let plugins: [PackageDescription.Target.PluginUsage] = development ? [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")] : []

let package = Package(
    name: "SwiftEnvironment",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SwiftEnvironment",
            targets: ["SwiftEnvironment"]
        )
    ],
    dependencies: packageDependencies,
    targets: [
        .target(
            name: "SwiftEnvironment",
            dependencies: ["Chary", "SwiftEnvironmentMacro"],
            plugins: plugins
        ),
        .macro(
            name: "SwiftEnvironmentMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "SwiftEnvironmentTests",
            dependencies: [
                "SwiftEnvironment",
                "SwiftEnvironmentMacro",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
