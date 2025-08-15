// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WhitelabelPaySDK",
	platforms: [
		.iOS(.v16),
		.macOS(.v13)
	],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WhitelabelPaySDK", targets: ["WLP"]),
    ],
    dependencies: [
		.package(url: "https://github.com/apple/swift-ntp.git", .upToNextMajor(from: "0.3.0")),
        .package(url: "https://github.com/andyzaharia/faro-otel-swift-exporter", exact: "1.0.0"),
    ],
    targets: [
		.binaryTarget(name: "WhitelabelPaySDK", path: "binary/WhitelabelPaySDK-v1.1.27.zip"),
		.target(
			name: "WLP",
			dependencies: [
				.target(name: "WhitelabelPaySDK"),
				.product(name: "FaroOtelExporter", package: "faro-otel-swift-exporter"),
				.product(name: "NTPClient", package: "swift-ntp")
			]
		),
    ]
)
