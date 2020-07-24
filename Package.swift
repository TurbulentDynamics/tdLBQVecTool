// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tdQVecTool",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "tdQVecLib",
            targets: ["tdQVecLib"]),
        .executable(
            name: "tdQVecTool",
            targets: ["tdQVecTool"]),
        .executable(
            name: "lsQVec",
            targets: ["lsQVec"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1")
//        .package(url: "https://github.com/apple/swift-numerics", from: "0.0.5"),
    ],
    targets: [
        .target(
            name: "tdQVecTool",
            dependencies: [
                "tdQVecLib",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
//                .product(name: "Numerics", package: "swift-numerics")
            ]
        ),
        .target(
            name: "lsQVec",
            dependencies: [
                "tdQVecLib",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .target(
            name: "tdQVecLib",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]),
        .testTarget(
            name: "tdQVecLibTests",
            dependencies: ["tdQVecLib"]
        )
    ]
)
