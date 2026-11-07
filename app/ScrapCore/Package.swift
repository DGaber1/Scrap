// swift-tools-version: 5.9
// ScrapCore: the platform-independent half of Scrap (REQ-D-01, REQ-D-02).
//
// Only the Swift standard library and Foundation are imported anywhere in
// this package. No SwiftUI, UIKit, SwiftData, or Combine.
import PackageDescription

let package = Package(
    name: "ScrapCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "ScrapCore", targets: ["ScrapCore"])
    ],
    targets: [
        .target(name: "ScrapCore"),
        .testTarget(name: "ScrapCoreTests", dependencies: ["ScrapCore"]),
    ]
)
