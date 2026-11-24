// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Tuneless",
    platforms: [.macOS(.v14)],
    products: [.executable(name: "tuneless", targets: ["Tuneless"])],
    targets: [
        .target(name: "TunelessCore"),
        .executableTarget(name: "Tuneless", dependencies: ["TunelessCore"]),
        .testTarget(name: "TunelessCoreTests", dependencies: ["TunelessCore"]),
    ],
    swiftLanguageModes: [.v6]
)
