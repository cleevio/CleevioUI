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
        .library(
            name: "InfoBar",
            targets: ["InfoBar"]),
    ],
    dependencies: [
        .package(url: "git@gitlab.cleevio.cz:cleevio-dev-ios/CleevioCore.git", .upToNextMajor(from: Version(2, 0, 0))),
        .package(url: "git@gitlab.cleevio.cz:cleevio-dev-ios/CleevioRouters.git", .upToNextMajor(from: "2.2.0-dev1"))
    ],
    targets: [
        .target(
            name: "CleevioUI",
            dependencies: [
                "CleevioCore"
            ]),
        .target(
            name: "InfoBar",
            dependencies: [
                "CleevioCore",
                "CleevioRouters",
                "CleevioUI"
            ]),
        .testTarget(
            name: "CleevioUITests",
            dependencies: ["CleevioUI"]),
    ]
)
