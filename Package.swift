// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iconset",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.0"),
    ],
    targets: [
        .executableTarget(
            name: "iconset",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources",
            swiftSettings: [
                .unsafeFlags(["--disable-sandbox --arch arm64 --arch x86_64"], .when(platforms: nil, configuration: .release))
            ]
        )
    ]
)
