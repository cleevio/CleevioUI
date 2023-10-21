// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CleevioUI",
    platforms: [
        .iOS(.v13)
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
    ]
)
