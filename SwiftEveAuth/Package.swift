// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftEveAuth",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftEveAuth",
            targets: ["SwiftEveAuth"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OAuthSwift/OAuthSwift.git", .upToNextMajor(from: "2.2.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftEveAuth",
            dependencies: [
                .product(name: "OAuthSwift", package: "OAuthSwift")
            ]
        ),
        .testTarget(
            name: "SwiftEveAuthTests",
            dependencies: ["SwiftEveAuth"]
        ),
    ]
)
