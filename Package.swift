// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "VaporAuthTemplate",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.3.0")),
        .package(url: "https://github.com/vapor/mysql-provider.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/vapor/leaf-provider.git", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/vapor/validation-provider.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/vapor/auth-provider.git", .upToNextMajor(from: "1.2.0"))
    ],
    targets: [
        .target(name: "App",
                dependencies: [
                    "Vapor",
                    "MySQLProvider",
                    "LeafProvider",
                    "ValidationProvider",
                    "AuthProvider"
                ],
                exclude: [
                    "Config",
                    "Public",
                    "Resources",
                ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "Testing"])
    ]
)

