// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "owj",
  products: [
    .library(name: "CSQLite", targets: ["CSQLite"]),
  ],
  targets: [
    .target(
      name: "CSQLite",
      dependencies: ["sqlite"]
    ),
    .target(
      name: "sqlite",
      path: "src"
    ),
    .testTarget(
      name: "CSQLiteTests",
      dependencies: ["CSQLite"]
    )
  ]
)
