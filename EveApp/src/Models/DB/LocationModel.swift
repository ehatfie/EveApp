//
//  LocationModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/2/24.
//

import Foundation
import FluentSQLiteDriver

final class LocationModel: Model {
  static let schema = Schemas.locationModel.rawValue
  
  @ID(key: .id) var id: UUID?
  
  init() { }
  
  struct ModelMigration: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
      try await database.schema(LocationModel.schema)
        .id()
//        .field("characterId", .string, .required)
//        .field("refreshToken", .string, .required)
//        .field("tokenType", .string, .required)
//        .field("accessToken", .string, .required)
//        .field("expiration", .int64, .required)
        .create()
    }
    
    func revert(on database: any FluentKit.Database) async throws {
      try await database.schema(LocationModel.schema)
        .delete()
    }
  }
}
