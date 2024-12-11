//
//  KillmailModel.swift
//  TestPackage1
//
//  Created by Erik Hatfield on 9/10/24.
//

import Foundation
import FluentSQLiteDriver

final public class ZKillmailModel: Model {
    static public let schema = Schemas.Killmail.zkill.rawValue
    
    @ID(key: .id) public var id: UUID?
    @Field(key: "killmail_id") public var killmailId: Int64
    @Field(key: "location_id") public var locationId: Int64
    @Field(key: "hash") public var hash: String
    @Field(key: "fitted_value") public var fittedValue: Double
    @Field(key: "dropped_value") public var droppedValue: Double
    @Field(key: "destroyed_value") public var destroyedValue: Double
    @Field(key: "total_value") public var totalValue: Double
    @Field(key: "points") public var points: Int
    @Field(key: "npc") public var npc: Bool
    @Field(key: "solo") public var solo: Bool
    @Field(key: "awox") public var awox: Bool
    @Field(key: "labels") public var labels: String
    
    public init() { }
    
    public init(
        id: UUID? = UUID(),
        killmailId: Int64,
        locationId: Int64,
        hash: String,
        fittedValue: Double,
        droppedValue: Double,
        destroyedValue: Double,
        totalValue: Double,
        points: Int,
        npc: Bool,
        solo: Bool,
        awox: Bool,
        labels: String
    ) {
        self.id = id
        self.killmailId = killmailId
        self.locationId = locationId
        self.hash = hash
        self.fittedValue = fittedValue
        self.droppedValue = droppedValue
        self.destroyedValue = destroyedValue
        self.totalValue = totalValue
        self.points = points
        self.npc = npc
        self.solo = solo
        self.awox = awox
        self.labels = labels
    }
    
    public convenience init(data: ZKillResponseData) {
        let zkb = data.zkb
        self.init(
            killmailId: data.killmail_id,
            locationId: zkb.locationID,
            hash: zkb.hash,
            fittedValue: zkb.fittedValue,
            droppedValue: zkb.droppedValue,
            destroyedValue: zkb.destroyedValue,
            totalValue: zkb.totalValue,
            points: zkb.points,
            npc: zkb.npc,
            solo: zkb.solo,
            awox: zkb.awox,
            labels: zkb.labels.joined(separator: ";")
        )
    }
    public struct ModelMigration: AsyncMigration {
        public init() { }
        
        public func prepare(on database: Database) async throws {
            try await database.schema(ZKillmailModel.schema)
                .id()
                .field("killmail_id", .int64, .required)
                .field("location_id", .int64, .required)
                .field("hash", .string, .required)
                .field("fitted_value", .double, .required)
                .field("dropped_value", .double, .required)
                .field("destroyed_value", .double, .required)
                .field("total_value", .double, .required)
                .field("points", .int, .required)
                .field("npc", .bool, .required)
                .field("solo", .bool, .required)
                .field("awox", .bool, .required)
                .field("labels", .string, .required)
                .unique(on: "killmail_id")
                .create()
        }
        
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(ZKillmailModel.schema)
                .delete()
        }
    }
}

/*
 public struct ZKillMailData: Codable {
     public let locationID: Int64
     public let hash: String
     public let fittedValue: Double
     public let droppedValue: Double
     public let destroyedValue: Double
     public let totalValue: Double
     public let points: Int
     public let npc: Bool
     public let solo: Bool
     public let awox: Bool
     public let labels: [String]
 }
*/
