//
//  owj+misc.swift
//  owj
//
//  Created by Fang Ling on 2023/11/14.
//

import Foundation

extension String {
  /*
   * API REFERENCES:
   * A string constant is formed by enclosing the string in single quotes (').
   * A single quote within the string can be encoded by putting two single
   * quotes in a row - as in Pascal.
   */
  public func sqlite_string_literal() -> String {
    self.replacingOccurrences(of: "'", with: "''")
  }
}
