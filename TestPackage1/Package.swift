// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
// this is in the app 
let package = Package(
    name: "TestPackage1",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TestPackage1",
            targets: ["TestPackage1"]
        ),
        
    ],
    //.dependency(name: "fluent-sqlite-driver", url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "1.0.0"),
    dependencies: [
        .package(url: "https://github.com/apple/swift-atomics.git",from: .init(1, 2, 0)),
        .package(url: "https://github.com/vapor/vapor.git", from: .init(4, 5, 0)),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: .init(4, 5, 0)),
        .package(url: "https://github.com/vapor/fluent.git", .upToNextMajor(from: "4.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TestPackage1",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .testTarget(
            name: "TestPackage1Tests",
            dependencies: ["TestPackage1"]
        ),
    ]
)
