// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SwiftEnvironment",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SwiftEnvironment",
            targets: ["SwiftEnvironment"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.1"),
        .package(url: "https://github.com/hainayanda/Chary.git", .upToNextMajor(from: "1.0.7"))
    ],
    targets: [
        .target(
            name: "SwiftEnvironment",
            dependencies: ["SwiftEnvironmentMacro", "Chary"]
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
                "SwiftEnvironment", "SwiftEnvironmentMacro",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
