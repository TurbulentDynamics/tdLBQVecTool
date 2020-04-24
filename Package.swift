// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tdQVecTool",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "tdQVecLibrary",
            targets: ["tdQVecCore"]),
        .executable(
            name: "tdQVecTool",
            targets: ["tdQVecTool"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/turbulentdynamics/tdLBApi.git", from: "0.0.1")
    ],
    targets: [
        .target(
            name: "tdQVecTool",
            dependencies: [
                "tdQVecCore",
            .product(name: "ArgumentParser", package: "swift-argument-parser")]
        ),
        .target(
            name: "tdQVecCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "tdLBApi", package: "tdLBApi")
        ]),
        .testTarget(
            name: "tdQVecCoreTests",
            dependencies: ["tdQVecCore"]
        )
    ]
)



