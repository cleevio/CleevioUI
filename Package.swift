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
            targets: ["CleevioUI"]),
    ],
    dependencies: [
        .package(url: "git@gitlab.cleevio.cz:cleevio-dev-ios/CleevioFramework-ios.git", branch: "feature/reworked-cleevio-framework-packages")
    ],
    targets: [
        .target(
            name: "CleevioUI",
            dependencies: [
                .product(name: "CleevioCore", package: "CleevioFramework-ios")
            ]),
        .testTarget(
            name: "CleevioUITests",
            dependencies: ["CleevioUI"]),
    ]
)
