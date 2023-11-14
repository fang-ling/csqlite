## CSQLite
A minimal Swift wrapper around SQLite.

## Usage

```swift
  let db = try SQLite(":memory:") /* In-memory SQLite3 database */
  var result = try db.run(
    """
    CREATE TABLE IF NOT EXISTS "users" (
      "id" INTEGER PRIMARY KEY,
      "name" TEXT,
      "email" TEXT NOT NULL UNIQUE
    );
    INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@test.com');
    INSERT INTO "users" ("name", "email") VALUES ('Tracy', 'tracy@test.com');
    SELECT * FROM "users";
    """
  )
  // [
  //   ["id" : "1", "name" : "Alice", "email" : "alice@test.com"],
  //   ["id" : "2", "name" : "Tracy", "email" : "tracy@test.com"]
  // ]

  try db.run(#"DELETE FROM "users" WHERE ("id" = 1);"#)
  result = try db.run(#"SELECT * FROM "users";"#)
  // [["id" : "2", "name" : "Tracy", "email" : "tracy@test.com"]]

  do {
    try db.run(#"SELECT * FOM "Users";"#) /* Buggy sql stmt */
  } catch SQLiteError.error(let msg) {
    print(msg)
    // Prints "SQL logic error"
  }
```

`CSQLite` also comes with a convenience function that helps you escape a string literal to a valid SQLite string literal. Specifically, it is used to handle single quotes within the string.

```swift
"Placeholder".sqlite_string_literal()
```

## Using CSQLite in your project

To use CSQLite in a SwiftPM project:

1. Add the following line to the dependencies in your Package.swift file:

```swift
.package(url: "https://github.com/fang-ling/csqlite", from: "0.0.4")
```

2. Add `CSQLite` as a dependency for your target:

```swift
.target(name: "MyTarget", dependencies: [
  .product(name: "CSQLite", package: "csqlite"),
  "AnotherModule"
]),
```

3. Add `import CSQLite` in your source code.
