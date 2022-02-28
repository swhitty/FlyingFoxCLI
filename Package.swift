// swift-tools-version:5.5

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
        .package(url: "https://github.com/swhitty/FlyingFox.git", .upToNextMajor(from: "0.3.1"))
    ],
    targets: [
        .executableTarget(
            name: "FlyingFoxCLI",
            dependencies: [
                .product(name: "FlyingFox", package: "FlyingFox")
            ],
			path: "Sources"
		)
    ]
)
