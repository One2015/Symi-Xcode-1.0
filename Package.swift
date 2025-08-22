// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "Symi",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Symi",
            targets: ["Symi"]),
    ],
    targets: [
        .target(
            name: "Symi",
            dependencies: [],
            path: ".",
            sources: [
                "App",
                "Core", 
                "Features"
            ]
        ),
    ]
)