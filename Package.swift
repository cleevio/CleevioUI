// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CleevioUI",
    platforms: [
        .iOS(.v13), .watchOS(.v8)
    ],
    products: [
        .library(
            name: "CleevioUI",
            targets: ["CleevioUI"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CleevioUI",
            dependencies: []
        ),
        .testTarget(
            name: "CleevioUITests",
            dependencies: ["CleevioUI"]),
    ],
    swiftLanguageModes: [.v6]
)
