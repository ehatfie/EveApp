//
//  LocationModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/2/24.
//

import Foundation
import FluentSQLiteDriver

final public class LocationModel: Model {
  static public let schema = Schemas.locationModel.rawValue
  
  @ID(key: .id) public var id: UUID?
  
    public init() { }
  
    public struct ModelMigration: AsyncMigration {
        public func prepare(on database: FluentKit.Database) async throws {
      try await database.schema(LocationModel.schema)
        .id()
//        .field("characterId", .string, .required)
//        .field("refreshToken", .string, .required)
//        .field("tokenType", .string, .required)
//        .field("accessToken", .string, .required)
//        .field("expiration", .int64, .required)
        .create()
    }
    
        public func revert(on database: any FluentKit.Database) async throws {
      try await database.schema(LocationModel.schema)
        .delete()
    }
  }
}
