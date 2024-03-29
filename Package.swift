// swift-tools-version:5.7

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
        .package(url: "https://github.com/swhitty/FlyingFox.git", .upToNextMajor(from: "0.12.2"))
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
            ]
		)
    ]
)
