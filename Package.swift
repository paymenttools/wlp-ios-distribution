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
        .package(url: "https://github.com/andyzaharia/faro-otel-swift-exporter", branch: "main"),
//		.package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.17.0")),
//		.package(url: "https://github.com/apple/swift-docc-plugin.git", .upToNextMajor(from: "1.0.0")),
//		.package(url: "https://github.com/paymenttools/wlp-enroll-kit.git", branch: "main"),
//		.package(url: "https://github.com/open-telemetry/opentelemetry-swift.git", .upToNextMinor(from: "1.16.0")),
    ],
    targets: [
		.binaryTarget(name: "WhitelabelPaySDK", path: "binary/WhitelabelPaySDK-v1.1.21.zip"),
		.target(
			name: "WLP",
			dependencies: [
				.target(name: "WhitelabelPaySDK"),
//				.product(name: "OpenTelemetryApi", package: "opentelemetry-swift"),
//				.product(name: "OpenTelemetrySdk", package: "opentelemetry-swift"),
				.product(name: "FaroOtelExporter", package: "faro-otel-swift-exporter"),
//				.product(name: "NIO", package: "swift-nio"),
			]
		),
    ]
)
