import PackageDescription

let package = Package(
  name: "MySQL",
  targets: [
    Target(
      name: "Example",
      dependencies: [.Target(name: "MySQL")]),
    Target(name: "Example"),
  ],
	//exclude: ["Tests"],
  dependencies: [
    .Package(url: "https://github.com/notonthehighstreet/swift-libmysql", majorVersion: 0, minor: 0)
  ]
)
