// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WhitelabelPaySDK",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WhitelabelPaySDK",
            targets: ["WhitelabelPaySDK"]),
    ],
    targets: [
        .binaryTarget(name: "WhitelabelPaySDK", path: "binary/WhitelabelPaySDK-v1.1.20.zip")
    ]
)
