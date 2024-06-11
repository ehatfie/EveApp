//
//  CorporationInfoModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/5/24.
//

import Foundation
import FluentSQLiteDriver

final class CorporationInfoModel: Model {
  static let schema = Schemas.corporationInfoModel.rawValue
  
  @ID(key: .id) var id: UUID?
  @Field(key: "corporationId") var corporationId: Int32
  @Field(key: "allianceId") var allianceId: Int?
  @Field(key: "ceoId") var ceoId: Int
  @Field(key: "creatorId") var creatorId: Int
  @Field(key: "dateFounded") var dateFounded: String?
  @Field(key: "description") var description: String?
  @Field(key: "factionId") var factionId: Int?
  @Field(key: "homeStationId") var homeStationId: Int?
  @Field(key: "memberCount") var memberCount: Int
  @Field(key: "name") var name: String
  @Field(key: "shares") var shares: Int64?
  @Field(key: "taxRate") var taxRate: Float
  @Field(key: "ticker") var ticker: String
  @Field(key: "url") var url: String?
  @Field(key: "warEligible") var warEligible: Bool?
  
  init() { }
  
  init(from model: GetCorporationInfoResponse, corporationId: Int32) {
    self.allianceId = model.allianceId
    self.corporationId = corporationId
    self.ceoId = model.ceoId
    self.creatorId = model.creatorId
    self.dateFounded = model.dateFounded
    self.description = model._description
    self.factionId = model.factionId
    self.homeStationId = model.homeStationId
    self.memberCount = model.memberCount
    self.name = model.name
    self.shares = model.shares
    self.taxRate = model.taxRate
    self.ticker = model.ticker
    self.url = model.url
    self.warEligible = model.warEligible
  }
  
  struct ModelMigration: AsyncMigration {
    
    func prepare(on database: FluentKit.Database) async throws {
      try await database.schema(CorporationInfoModel.schema)
        .id()
        .field("corporationId", .int32, .required)
        .field("allianceId", .int)
        .field("ceoId", .int, .required)
        .field("creatorId", .int, .required)
        .field("dateFounded", .string)
        .field("description", .string)
        .field("factionId", .int)
        .field("homeStationId", .int)
        .field("memberCount", .int, .required)
        .field("name", .string, .required)
        .field("shares", .int64)
        .field("taxRate", .float, .required)
        .field("ticker", .string, .required)
        .field("url", .string)
        .field("warEligible", .bool)
        .unique(on: "corporationId")
        .create()
    }
    
    func revert(on database: any FluentKit.Database) async throws {
      try await database.schema(CorporationInfoModel.schema)
        .delete()
    }
  }
}


/**
 /** ID of the alliance that corporation is a member of, if any */
 public var allianceId: Int?
 /** ceo_id integer */
 public var ceoId: Int
 /** creator_id integer */
 public var creatorId: Int
 /** date_founded string */
 public var dateFounded: String?
 /** description string */
 public var _description: String?
 /** faction_id integer */
 public var factionId: Int?
 /** home_station_id integer */
 public var homeStationId: Int?
 /** member_count integer */
 public var memberCount: Int
 /** the full name of the corporation */
 public var name: String
 /** shares integer */
 public var shares: Int64?
 /** tax_rate number */
 public var taxRate: Float
 /** the short name of the corporation */
 public var ticker: String
 /** url string */
 public var url: String?
 /** war_eligible boolean */
 public var warEligible: Bool?
 */
