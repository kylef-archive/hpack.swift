import PackageDescription


let package = Package(
  name: "hpack",
  dependencies: [
    .Package(url: "https://github.com/kylef/Spectre", majorVersion: 0, minor: 7),
  ]
)
