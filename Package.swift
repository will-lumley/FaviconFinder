// swift-tools-version:6.0.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Linux)
let dependencies: [PackageDescription.Package.Dependency] = [
    // URLSession on Linux is notoriously unreliable and freezes, so this is used instead (only for Linux)
    .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.22.0"),

    // SwiftSoup is used to parse the HTML tree
    .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.7")
]

let targetDependencies: [Target.Dependency] = [
    "SwiftSoup",
    .product(name: "AsyncHTTPClient", package: "async-http-client")
]

let plugins: [Target.PluginUsage] = [

]

#else
let dependencies: [PackageDescription.Package.Dependency] = [
    // SwiftSoup is used to parse the HTML tree
    .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.3.7"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.3"),
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.55.1")
]

let targetDependencies: [Target.Dependency] = [
    "SwiftSoup"
]

let plugins: [Target.PluginUsage] = [
    .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
]

#endif

let package = Package(
    name: "FaviconFinder",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "FaviconFinder",
            targets: [
                "FaviconFinder"
            ]
        )
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "FaviconFinder",
            dependencies: targetDependencies,
            plugins: plugins
        ),

        .testTarget(
            name: "FaviconFinderTests",
            dependencies: [
                "FaviconFinder"
            ],
            plugins: plugins
        )
    ]
)
