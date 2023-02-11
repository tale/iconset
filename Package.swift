// swift-tools-version:5.5

import PackageDescription

let package = Package(
	name: "Iconset",
	platforms: [
		.macOS(.v10_15)
	],
	products: [
		.executable(name: "iconset", targets: ["Iconset", "CarbonWrapper"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
		.package(url: "https://github.com/luoxiu/Chalk", from: "0.2.0")
	],
	targets: [
		.executableTarget(
			name: "Iconset",
			dependencies: [
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
				.product(name: "Chalk", package: "Chalk")
			],
			path: "Sources/Iconset"
		),
		.target(
			name: "CarbonWrapper",
			path: "Sources/Carbon",
			publicHeadersPath: "Include"
		)
	]
)
