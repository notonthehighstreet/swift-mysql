import PackageDescription

let package = Package(
  name: "MySQL",
  targets: [
    Target(
      name: "Example",
      dependencies: [.Target(name: "MySQL")]),
    Target(name: "MySQL"),
  ],
  dependencies: [
    .Package(url: "https://github.com/nicholasjackson/swift-libmysql", majorVersion: 0, minor: 1)
  ]
)
