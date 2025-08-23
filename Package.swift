// swift-tools-version:6.1

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
        .package(url: "https://github.com/swhitty/FlyingFox.git", branch: "main")
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
                .swiftLanguageMode(.v6),
                .enableUpcomingFeature("ExistentialAny")
            ]
		)
    ]
)
