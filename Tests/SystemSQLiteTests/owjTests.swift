import XCTest
@testable import SystemSQLite

final class owjTests: XCTestCase {
  func test_owj() throws {
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
    var table = [
      ["id" : "1", "name" : "Alice", "email" : "alice@test.com"],
      ["id" : "2", "name" : "Tracy", "email" : "tracy@test.com"]
    ]
    XCTAssertEqual(result, table)
    
    try db.run(#"DELETE FROM "users" WHERE ("id" = 1);"#)
    result = try db.run(#"SELECT * FROM "users";"#)
    table.removeFirst()
    XCTAssertEqual(result, table)
    
    do {
      try db.run(#"SELECT * FOM "Users";"#) /* Buggy sql stmt */
    } catch SQLiteError.error(let msg) {
      XCTAssertEqual(msg, "SQL logic error")
    }
    
    let name = "M'N's''".sqlite_string_literal()
    try db.run(
      """
      INSERT INTO "users" ("name", "email") VALUES ('\(name)', 'test@test.com');
      """
    )
    table.append(["id" : "3", "name" : "M'N's''", "email" : "test@test.com"])
    result = try db.run(#"SELECT * FROM "users";"#)
    XCTAssertEqual(result, table)
  }
  
  func test_misc() {
    XCTAssertEqual(
      "It's Bob's item.".sqlite_string_literal(),
      "It''s Bob''s item."
    )
  }
}
