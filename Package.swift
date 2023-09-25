// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Rubicon",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "Rubicon",
            targets: ["Rubicon"]
        ),
        .executable(
            name: "rubicon-cli",
            targets: ["rubicon-cli"]
        ),
        .plugin(
            name: "RubiconPlugin",
            targets: ["RubiconPlugin"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", revision: "335d3417646a6e146fc0abcfc03104c63c46c52a"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.2"),
    ],
    targets: [
        .target(
            name: "Rubicon",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ]
        ),
        .plugin(
            name: "RubiconPlugin",
            capability: .command(
                intent: .custom(
                    verb: "generate-mocks",
                    description: "Generate mocks for the package"
                ), permissions: [
                    .writeToPackageDirectory(reason: "This command adds test doubles for you test code.")
                ]
            ),
            dependencies: [
                .target(name: "rubicon-cli")
            ]
        ),
        .executableTarget(
            name: "rubicon-cli",
            dependencies: [
                "Rubicon",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "RubiconTests",
            dependencies: ["Rubicon"]
        ),
    ]
)
