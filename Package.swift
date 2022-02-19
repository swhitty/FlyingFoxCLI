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
		.package(name: "FlyingFox", url: "https://github.com/swhitty/FlyingFox.git", branch: "main")
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