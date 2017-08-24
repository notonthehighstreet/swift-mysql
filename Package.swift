// swift-tools-version:3.1
import PackageDescription

let package = Package(
  name: "MySQL",
  targets: [
    Target(name: "MySQLTests", dependencies: ["MySQL"]),
    Target(name: "IntegrationTests", dependencies: ["MySQL"]),
    Target(name: "MySQL"),
  ],
  dependencies: [
    .Package(url: "https://github.com/nicholasjackson/swift-libmysql", majorVersion: 0, minor: 1)
  ]
)
