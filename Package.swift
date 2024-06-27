// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FaceDetectionMediaPipe",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FaceDetectionMediaPipe",
            targets: ["FaceDetectionMediaPipe"]),
    ],
    dependencies: [
        .package(url: "https://github.com/AppliedRecognition/Ver-ID-Common-Types-Apple.git", revision: "74b77e3dea2d19f4f22b27b7437c40c38852bdbf")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FaceDetectionMediaPipe",
            dependencies: [
                "MediaPipeTasksVision",
                "MediaPipeTasksCommon",
                "LibMediaPipeTasksCommon",
                .product(
                    name: "VerIDCommonTypes",
                    package: "Ver-ID-Common-Types-Apple"
                )
            ],
            resources: [
                .copy("Resources")
            ],
            swiftSettings: [
                .define("SPM"),
                .interoperabilityMode(.Cxx)
            ],
            linkerSettings: [
                .unsafeFlags(["-ObjC", "-lc++", "-lMediaPipeTasksCommon"])
            ]),
        .binaryTarget(
            name: "MediaPipeTasksVision",
            path: "Frameworks/MediaPipeTasksVision.xcframework"),
        .binaryTarget(
            name: "MediaPipeTasksCommon",
            path: "Frameworks/MediaPipeTasksCommon.xcframework"),
        .binaryTarget(
            name: "LibMediaPipeTasksCommon",
            path: "Frameworks/LibMediaPipeTasksCommon.xcframework"),
        .testTarget(
            name: "FaceDetectionMediaPipeTests",
            dependencies: ["FaceDetectionMediaPipe"],
            resources: [
                .copy("Resources")
            ],
            swiftSettings: [
                .define("SPM"),
                .interoperabilityMode(.Cxx)
            ])
    ]
)
