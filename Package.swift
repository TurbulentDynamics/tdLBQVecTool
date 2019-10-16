// swift-tools-version:5.1
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
        .package(
            url: "https://github.com/apple/swift-log.git",
            from: "1.0.0"
        )
    ],
    targets: [
        .target(
            name: "tdQVecTool",
            dependencies: ["tdQVecCore"]
        ),
        .target(
            name: "tdQVecCore",
            dependencies: ["Logging"]
        ),
        .testTarget(
            name: "tdQVecCoreTests",
            dependencies: ["tdQVecCore"]
        )
    ]
)



