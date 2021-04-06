// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tdLBQVecTool",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "tdLBQVecLib",
            targets: ["QVecLib"]),
        .executable(
            name: "tdLBQVecTool",
            targets: ["QVecTool"]),
        .executable(
            name: "lsLBQVec",
            targets: ["lsQVec"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.1"),
        .package(url: "https://github.com/turbulentdynamics/tdLBSwiftApi", from: "0.0.5"),
        .package(name: "SwiftImage", url: "https://github.com/koher/swift-image.git", from: "0.7.0")
//        .package(url: "https://github.com/apple/swift-numerics", from: "0.0.5"),
    ],
    targets: [
        .target(
            name: "QVecLib",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SwiftImage", package: "SwiftImage"),
                .product(name: "tdLBSwiftApi", package: "tdLBSwiftApi")
//                .product(name: "Numerics", package: "swift-numerics")
            ]),
        .target(
            name: "QVecTool",
            dependencies: [
                "QVecLib",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .target(
            name: "lsQVec",
            dependencies: [
                "QVecLib",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .testTarget(
            name: "QVecLibTests",
            dependencies: ["QVecLib"]
        )
    ]
)
