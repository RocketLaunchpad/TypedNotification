// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "TypedNotification",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v10)
    ],
    products: [
        .library(name: "TypedNotification", targets: ["TypedNotification"])
    ],
    targets: [
        .target(name: "TypedNotification"),
        .testTarget(name: "TypedNotificationTests", dependencies: ["TypedNotification"])
    ]
)

