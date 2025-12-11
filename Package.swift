// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "StudKit",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "StudKit",
            targets: ["StudKit"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "StudKit",
            dependencies: [],
            path: "Sources")
    ]
)
