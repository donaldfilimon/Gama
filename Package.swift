// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "gama",
    products: [
        .executable(name: "Gama", targets: ["Gama"])
    ],
    targets: [
        .executableTarget(name: "Gama", dependencies: [])
    ],
    swiftLanguageModes: [.v6]
)