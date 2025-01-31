//
//  CorporationInfoModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/5/24.
//

import FluentSQLiteDriver
import Foundation

final public class CorporationInfoModel: Model, @unchecked Sendable {
    static public let schema = Schemas.corporationInfoModel.rawValue

    @ID(key: .id) public var id: UUID?
    @Field(key: "corporationId") public var corporationId: Int32
    @Field(key: "allianceId") public var allianceId: Int?
    @Field(key: "ceoId") public var ceoId: Int
    @Field(key: "creatorId") public var creatorId: Int
    @Field(key: "dateFounded") public var dateFounded: String?
    @Field(key: "description") public var description: String?
    @Field(key: "factionId") public var factionId: Int?
    @Field(key: "homeStationId") public var homeStationId: Int?
    @Field(key: "memberCount") public var memberCount: Int
    @Field(key: "name") public var name: String
    @Field(key: "shares") public var shares: Int64?
    @Field(key: "taxRate") public var taxRate: Float
    @Field(key: "ticker") public var ticker: String
    @Field(key: "url") public var url: String?
    @Field(key: "warEligible") public var warEligible: Bool?

    public init() {}

    public init(from model: GetCorporationInfoResponse, corporationId: Int32) {
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

    public struct ModelMigration: AsyncMigration {
        public init() {}
        public func prepare(on database: FluentKit.Database) async throws {
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

        public func revert(on database: any FluentKit.Database) async throws {
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
