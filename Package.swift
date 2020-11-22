// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MotionOrientation",
    products: [
        .library(
            name: "MotionOrientation",
            targets: ["MotionOrientation"]
        )
    ],
    targets: [
        .target(
            name: "MotionOrientation",
            path: ".",
            exclude: [
                "Demo",
                "LICENSE",
                "MotionOrientation.podspec",
                "README.md"
            ],
            publicHeadersPath: "."
        )
    ]
)
