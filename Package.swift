// swift-tools-version: 6.0
import PackageDescription

// Test harness for the pure-Swift core (Models + Services). The SwiftUI layer
// is deliberately outside this package so `swift test` runs on the host in
// seconds without a simulator. When the Xcode app target exists, Models,
// Services and Screens all compile into it as one module — which is why the
// core API is internal and the tests use @testable.
let package = Package(
    name: "BridgeBuddies",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "BridgeBuddies", targets: ["BridgeBuddies"])
    ],
    targets: [
        .target(
            name: "BridgeBuddies",
            path: "BridgeBuddies/BridgeBuddies",
            sources: ["Models", "Services"]
        ),
        .testTarget(
            name: "BridgeBuddiesTests",
            dependencies: ["BridgeBuddies"],
            path: "BridgeBuddies/Tests/CoreTests"
        )
    ]
)
