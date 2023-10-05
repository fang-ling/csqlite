// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "owj",
  products: [
    .library(name: "CSQLite", targets: ["owj"]),
  ],
  targets: [
    .target(
      name: "owj",
      dependencies: ["sqlite"]
    ),
    .target(
      name: "sqlite",
      path: "src"
    ),
    .testTarget(
      name: "owjTests",
      dependencies: ["owj"]
    )
  ]
)
