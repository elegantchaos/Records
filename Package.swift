// swift-tools-version:5.3

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 19/07/2021.
//  All code (c) 2021 - present day, Elegant Chaos.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import PackageDescription

let package = Package(
    name: "Records",
    platforms: [
        .macOS(.v10_13), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Records",
            targets: ["Records"]),
    ],
    dependencies: [
        
        .package(url: "https://github.com/elegantchaos/CoreDataExtensions.git", from: "1.0.0"),
        .package(url: "https://github.com/elegantchaos/XCTestExtensions.git", from: "1.3.1")
    ],
    targets: [
        .target(
            name: "Records",
            dependencies: [
                "CoreDataExtensions"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "RecordsTests",
            dependencies: ["Records", "XCTestExtensions"]),
    ]
)
