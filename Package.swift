// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Linux)
let dependencies: [PackageDescription.Package.Dependency] = [
    // URLSession on Linux is notoriously unreliable and freezes, so this is used instead (only for Linux)
    .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.9.0"),

    // SwiftSoup is used to parse the HTML tree
    .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.7")
]

let targetDependencies: [Target.Dependency] = [
    "SwiftSoup",
    .product(name: "AsyncHTTPClient", package: "async-http-client")
]

#else
let dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.9.0"),
    // SwiftSoup is used to parse the HTML tree
    .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.7")
]

let targetDependencies: [Target.Dependency] = [
    "SwiftSoup",
    .product(name: "AsyncHTTPClient", package: "async-http-client")
]
#endif

let package = Package(
    name: "FaviconFinder",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8), .tvOS(.v15)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "FaviconFinder",
            targets: ["FaviconFinder"]),
    ],
    dependencies: dependencies,
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "FaviconFinder",
            dependencies: targetDependencies
        ),

        .testTarget(name: "FaviconFinderTests", dependencies: ["FaviconFinder"]),
    ]
)
