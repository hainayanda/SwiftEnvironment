// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

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
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/hainayanda/Chary.git", .upToNextMajor(from: "1.0.7")),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.58.2")
    ],
    targets: [
        .target(
            name: "SwiftEnvironment",
            dependencies: ["Chary"],
            plugins: [
                .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
            ]
        ),
        .testTarget(
            name: "SwiftEnvironmentTests",
            dependencies: [
                "SwiftEnvironment"
            ]
        ),
    ]
)
