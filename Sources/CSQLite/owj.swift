//
//  owj.swift
//  owj
//
//  Created by Fang Ling on 2022/11/19.
//

import Foundation
import sqlite

//typealias SQLite3Pointer = OpaquePointer
//typealias SQLite3StmtPointer = OpaquePointer
//public typealias SQLite3Row = [String: String]

/* Swift wrapper of C library sqlite */
public class SQLite {
  var db: OpaquePointer? = nil
  
  // MARK: - init & deinit
  /*
   * API REFERENCES:
   * The sqlite3_open_v2() interface works like sqlite3_open() except that it
   * accepts two additional parameters for additional control over the new
   * database connection.
   *
   * Regardless of the compile-time or start-time settings, URI filenames can
   * be enabled for individual database connections by including the
   * SQLITE_OPEN_URI bit in the set of bits passed as the F parameter to
   * sqlite3_open_v2(N,P,F,V).
   *
   * 'sqlite3_config' is unavailable: Variadic function is unavailable
   *
   * The default encoding will be UTF-8 for databases created using
   * sqlite3_open() or sqlite3_open_v2().
   */
  public init(_ location: String) throws {
    let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_URI
    try check_error(sqlite3_open_v2(location, &db, flags, nil))
  }
  
  /*
   * API REFERENCES:
   * The sqlite3_close() and sqlite3_close_v2() routines are destructors for the
   * sqlite3 object. Calls to sqlite3_close() and sqlite3_close_v2() return
   * SQLITE_OK if the sqlite3 object is successfully destroyed and all
   * associated resources are deallocated.
   *
   * Calling sqlite3_close() or sqlite3_close_v2() with a NULL pointer argument
   * is a harmless no-op.
   */
  deinit {
    try! check_error(sqlite3_close(db))
  }
  
  // MARK: - run
  /*
   * API REFERENCES:
   * SQLITE_DONE means that the statement has finished executing successfully.
   * sqlite3_step() should not be called again.
   */
  /// Compiling and Run An SQL Statement
  @discardableResult
  public func exec<T: Codable>(_ sql: String, as: T.Type) throws -> [T] {
    var result = [T]()
    /* Prepare (Support multiple queries) */
    var pz_tail: UnsafePointer<CChar>?
    sql.withCString { ptr in
      pz_tail = ptr
    }
    while pz_tail?.pointee != 0 {
      var stmt: OpaquePointer? = nil
      try check_error(sqlite3_prepare_v2(db, pz_tail, -1, &stmt, &pz_tail))
      /* Query using sqlite3_step */
      var code = SQLITE_OK
      repeat {
        code = sqlite3_step(stmt)
        try check_error(code)
        var row = [String: Any]()
        for i in 0 ..< sqlite3_column_count(stmt) {
          let col_name = String(cString: sqlite3_column_name(stmt, i))
          switch sqlite3_column_type(stmt, i) {
          case SQLITE3_TEXT:
            row[col_name] = String(cString: sqlite3_column_text(stmt, i))
            break
          case SQLITE_INTEGER:
            row[col_name] = sqlite3_column_int(stmt, i)
            break
          case SQLITE_FLOAT:
            row[col_name] = sqlite3_column_double(stmt, i)
            break
          case SQLITE_NULL:
            row[col_name] = nil
            break
          case SQLITE_BLOB:
            print("Error: BLOB type is not supported")
            break
          default: break
          }
        }
        if !row.isEmpty {
          try result.append(row.decode())
        }
      } while (code != SQLITE_DONE)
      sqlite3_finalize(stmt)
    }
    return result
  }
  
  // MARK: - Error handling
  /*
   * API REFERENCES:
   * The sqlite3_errstr() interface returns the English-language text that
   * describes the result code, as UTF-8. Memory to hold the error message
   * string is managed internally and must not be freed by the application.
   */
  private func check_error(_ error_code: CInt) throws {
    if !SQLiteError.non_error_codes.contains(error_code) {
      throw SQLiteError.error(String(cString: sqlite3_errstr(error_code)))
    }
  }
}
