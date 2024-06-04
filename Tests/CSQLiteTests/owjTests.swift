import XCTest
@testable import CSQLite

final class owjTests: XCTestCase {
  func test_owj() throws {
    let db = try SQLite(":memory:") /* In-memory SQLite3 database */
    
    struct User: Codable, Equatable, Comparable {
      var id: Int
      var name: String
      var email: String
      
      static func < (lhs: User, rhs: User) -> Bool {
        return lhs.id < rhs.id
      }
    }
    
    var result = try db.exec(
      """
      CREATE TABLE IF NOT EXISTS "users" (
        "id" INTEGER PRIMARY KEY,
        "name" TEXT,
        "email" TEXT NOT NULL UNIQUE
      );
      INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@test.com');
      INSERT INTO "users" ("name", "email") VALUES ('Tracy', 'tracy@test.com');
      SELECT * FROM "users";
      """,
      as: User.self
    )
    
    var table = [
      User(id: 1, name: "Alice", email: "alice@test.com"),
      User(id: 2, name: "Tracy", email: "tracy@test.com")
    ]
    print(result)
    XCTAssertEqual(result.sorted(), table.sorted())
    
    try db.exec(#"DELETE FROM "users" WHERE ("id" = 1);"#, as: User.self)
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
    table.append(["id": "3", "name": "M'N's''", "email": "test@test.com"])
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
