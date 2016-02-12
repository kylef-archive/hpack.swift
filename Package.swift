import PackageDescription


let package = Package(
  name: "hpack",
  testDependencies: [
    .Package(url: "https://github.com/kylef/spectre-build", majorVersion: 0),
  ]
)
