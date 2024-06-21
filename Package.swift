// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "CopyableMacro",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "CopyableMacro",
            targets: ["CopyableMacroMacros"]
        ),
        .executable(
            name: "CopyableMacroClient",
            targets: ["CopyableMacroClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .macro(
            name: "CopyableMacroMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(name: "CopyableMacro", dependencies: ["CopyableMacroMacros"]),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "CopyableMacroClient", dependencies: ["CopyableMacro"]),
        .testTarget(
            name: "CopyableMacroTests",
            dependencies: [
                "CopyableMacroMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
