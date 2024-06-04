//
//  owj+error.swift
//  owj
//
//  Created by Fang Ling on 2023/11/13.
//

import Foundation
import sqlite

public enum SQLiteError: Error {
  /*
   * API REFERENCES:
   * There are only a few non-error result codes: SQLITE_OK, SQLITE_ROW,
   * and SQLITE_DONE.
   */
  static let non_error_codes = Set([SQLITE_OK, SQLITE_ROW, SQLITE_DONE])
  
  case error(String)
}
