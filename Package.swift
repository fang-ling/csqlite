// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "owj",
  products: [
    .library(name: "SystemSQLite", targets: ["SystemSQLite"]),
  ],
  targets: [
    .target(
      name: "SystemSQLite",
      dependencies: ["sqlite"]
    ),
    .systemLibrary(name: "sqlite"),
    .testTarget(
      name: "SystemSQLiteTests",
      dependencies: ["SystemSQLite"]
    )
  ]
)
