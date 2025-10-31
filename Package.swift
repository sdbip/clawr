// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Oolang",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ooc", targets: ["Oolang"])
    ],
    targets: [
        .executableTarget(
            name: "Oolang",
            dependencies: ["IRGen"],
            resources: [
                .copy("headers")
            ]
        ),
        .testTarget(
            name: "OolangTests",
            dependencies: ["Oolang"],
            resources: [
                .copy("c-files"),
                .copy("oo-files"),
            ]
        ),
        .target(name: "Codegen"),
        .testTarget(
            name: "CodegenTests",
            dependencies: ["Codegen"]
        ),
        .target(
            name: "IRGen",
            dependencies: ["Parser", "Codegen"]
        ),
        .target(
            name: "Parser",
            dependencies: ["Lexer"]
        ),
        .testTarget(
            name: "ParserTests",
            dependencies: ["Parser"]
        ),
        .target(name: "Lexer"),
        .testTarget(
            name: "LexerTests",
            dependencies: ["Lexer"]
        ),
    ]
)
