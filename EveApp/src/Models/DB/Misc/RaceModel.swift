//
//  RaceModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 12/17/23.
//

import Foundation
import FluentKit

struct RaceData: Codable {
  let descriptionID: ThingName?
  let iconID: Int64?
  let nameID: ThingName
  let shipTypeID: Int64?
}

final class RaceModel: Model {
  static let schema = Schemas.raceModel.rawValue
  @ID(key: .id) var id: UUID?
  
  @Field(key: "raceID") var raceID: Int64
  @Field(key: "descriptionID") var descriptionID: String
  @Field(key: "iconID") var iconID: Int64?
  @Field(key: "nameID") var nameID: String
  @Field(key: "shipTypeID") var shipTypeID: Int64?
  
  init() { }
  
  init(raceID: Int64, raceData: RaceData) {
    self.id = UUID()
    self.raceID = raceID
    self.descriptionID = raceData.descriptionID?.en ?? ""
    self.iconID = raceData.iconID
    self.nameID = raceData.nameID.en ?? ""
    self.shipTypeID = raceData.shipTypeID
  }
  
  struct ModelMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
      try await database.schema(RaceModel.schema)
        .id()
        .field("raceID", .int64, .required)
        .field("descriptionID", .string, .required)
        .field("iconID", .int64)
        .field("nameID", .string, .required)
        .field("shipTypeID", .int64)
        .create()
    }
    
    func revert(on database: Database) async throws {
       try await database.schema(RaceModel.schema).delete()
    }
  }
}
