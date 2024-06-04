//
//  Dictionary+Decodable.swift
//
//
//  Created by Fang Ling on 2024/6/4.
//

import Foundation

extension Dictionary where Key == String, Value: Any {
  func decode<T: Codable>() throws -> T {
    let json = try JSONSerialization.data(withJSONObject: self)
    return try JSONDecoder().decode(T.self, from: json)
  }
}
