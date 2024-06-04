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
    .systemLibrary(name: "sqlite"),
    .testTarget(
      name: "CSQLiteTests",
      dependencies: ["CSQLite"]
    )
  ]
)
