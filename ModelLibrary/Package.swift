// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ModelLibrary",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ModelLibrary",
            targets: ["ModelLibrary"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: .init(4, 5, 0)),
        .package(url: "https://github.com/vapor/fluent.git", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "4.0.0")),
        .package(path: "../Packages/TestPackage3")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ModelLibrary",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "TestPackage3", package: "TestPackage3")
            ]
        ),
        .testTarget(
            name: "ModelLibraryTests",
            dependencies: ["ModelLibrary"]
        ),
    ]
)