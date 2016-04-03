import PackageDescription

let package = Package(
    name: "MySQL",
		targets: [Target(name: "MySQL")],
    dependencies: [
      .Package(url: "https://github.com/notonthehighstreet/swift-libmysql", majorVersion: 0, minor: 0)
    ]
)
