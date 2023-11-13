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
//public typealias SQLite3Row = [String : String]

/* Swift wrapper of C library sqlite */
public class SQLite {
  var db : OpaquePointer? = nil
  
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
  public init(_ location : String) throws {
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
  
  // MARK: - Error handling
  /*
   * API REFERENCES:
   * The sqlite3_errstr() interface returns the English-language text that
   * describes the result code, as UTF-8. Memory to hold the error message
   * string is managed internally and must not be freed by the application.
   */
  func check_error(_ error_code : CInt) throws {
    if !SQLiteError.non_error_codes.contains(error_code) {
      throw SQLiteError.error(String(cString: sqlite3_errstr(error_code)))
    }
  }
}

@discardableResult
public func exec(at path : String, sql : String) -> [SQLite3Row] {
  var result = [SQLite3Row]()
  /* Open db file */
  var db : SQLite3Pointer? = nil
  
  
//  if sqlite3_open_v2(path, &db, db_flag, nil) != SQLITE_OK {
//    fatalError(String(cString: sqlite3_errmsg(db!)))
//  }
  /* Prepare (Support multiple queries) */
  var pz_tail : UnsafePointer<CChar>?
  sql.withCString { ptr in
    pz_tail = ptr
  }
  while pz_tail?.pointee != 0 {
    var stmt : SQLite3StmtPointer? = nil
    if sqlite3_prepare_v2(db, pz_tail, -1, &stmt, &pz_tail) != SQLITE_OK {
      fatalError(String(cString: sqlite3_errmsg(db!)))
    }
    /* Query using sqlite3_step */
    var code = SQLITE_OK
    repeat {
      code = sqlite3_step(stmt)
      /* Generic error */
      if code == SQLITE_ERROR ||
          /* Abort due to constraint violation */
         code == SQLITE_CONSTRAINT {
        fatalError(String(cString: sqlite3_errmsg(db!)))
      }
      var row = SQLite3Row()
      for i in 0 ..< sqlite3_column_count(stmt) {
        let col = String(cString: sqlite3_column_name(stmt, i))
        switch sqlite3_column_type(stmt, i) {
          /* Currently only two type used */
        case SQLITE3_TEXT:
          row[col] = String(cString: sqlite3_column_text(stmt, i))
          break
        case SQLITE_INTEGER:
          row[col] = String(sqlite3_column_int(stmt, i))
        default: break
        }
      }
      if !row.isEmpty {
        result.append(row)
      }
    } while (code != SQLITE_DONE)
    /* 
     * SQLITE_DONE means that the statement has finished executing
     * successfully. sqlite3_step() should not be called again.
     */
    sqlite3_finalize(stmt)
  }
//  /* Deinit */
//  sqlite3_close(db)
  
  return result
}
