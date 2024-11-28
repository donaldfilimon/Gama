// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "gama",
    dependencies: [
        .package(url: "https://github.com/compnerd/swift-win32.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "Gama",
            dependencies: [
                "GamaEngine",
                .product(name: "SwiftWin32", package: "swift-win32"),
                .product(name: "SwiftWin32UI", package: "swift-win32"),
            ]
        ),
        .target(
            name: "GamaEngine",
            dependencies: [
                .product(name: "SwiftWin32", package: "swift-win32"),
                .product(name: "SwiftWin32UI", package: "swift-win32"),
                .product(name: "Collections", package: "swift-collections"),
            ]
        ),
        .testTarget(
            name: "GamaEngineTests",
            dependencies: ["GamaEngine"]
        ),
    ]
)
