// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "kaleidoscope-swift",
    platforms: [.macOS(.v11)],
    
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "LLVM", url: "https://github.com/llvm-swift/LLVMSwift.git", from: "0.8.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(name: "Kaleidoscope", dependencies: ["LLVM"],
                cSettings: [.unsafeFlags(["-I/usr/local/opt/llvm@11/lib"])]),

        .executableTarget(name: "Chapter1", dependencies: []),
        .executableTarget(name: "Chapter2", dependencies: []),
    ]
)
