import XCTest
@testable import CSQLite

final class owjTests: XCTestCase {
  func test_exec() throws {
    let result = exec(
      at: ":memory:", /* In-memory SQLite3 database */
      sql: """
           CREATE TABLE IF NOT EXISTS 'users' (
               'id' INTEGER PRIMARY KEY,
               'name' TEXT,
               'email' TEXT NOT NULL UNIQUE
           );
           INSERT INTO 'users' ('name', 'email') VALUES
               ('Alice', 'alice@test.com');
           INSERT INTO 'users' ('name', 'email') VALUES
               ('Tracy', 'tracy@test.com');
           SELECT * FROM 'users';
           """
    )
    let table = [["id" : "1", "name" : "Alice", "email" : "alice@test.com"],
                 ["id" : "2", "name" : "Tracy", "email" : "tracy@test.com"]]
    XCTAssertEqual(result, table)
  }
}
