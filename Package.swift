// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "FlyingFoxCLI",
	  platforms: [
        .macOS(.v10_15)
	    ],	
    products: [
  	  	.executable(name: "flyingfox", targets: ["FlyingFoxCLI"])
    ],
    dependencies: [
        .package(url: "https://github.com/swhitty/FlyingFox.git", .upToNextMajor(from: "0.19.0"))
    ],
    targets: [
        .executableTarget(
            name: "FlyingFoxCLI",
            dependencies: [
                .product(name: "FlyingFox", package: "FlyingFox")
            ],
			path: "Sources",
            resources: [
                .copy("HTML.bundle")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ],
            linkerSettings: [
                .linkedLibrary("crypto", .when(platforms: [.linux])),
                .linkedLibrary("icudata", .when(platforms: [.linux])),
                .linkedLibrary("icuuc", .when(platforms: [.linux])),
                .linkedLibrary("ssl", .when(platforms: [.linux])),
                .linkedLibrary("z", .when(platforms: [.linux]))
            ]
		)
    ]
)
