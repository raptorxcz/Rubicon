// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Rubicon",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Rubicon",
            targets: ["Rubicon"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", revision: "335d3417646a6e146fc0abcfc03104c63c46c52a"),
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
        .testTarget(
            name: "RubiconTests",
            dependencies: ["Rubicon"]
        ),
    ]
)
