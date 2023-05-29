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
        .package(url: "git@gitlab.cleevio.cz:cleevio-dev-ios/CleevioCore.git", .upToNextMajor(from: Version(2, 0, 0)))
    ],
    targets: [
        .target(
            name: "CleevioUI",
            dependencies: [
                "CleevioCore"
            ]),
        .testTarget(
            name: "CleevioUITests",
            dependencies: ["CleevioUI"]),
    ]
)
