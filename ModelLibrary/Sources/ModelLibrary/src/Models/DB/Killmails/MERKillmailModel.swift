//
//  MERKillmailModel.swift
//  ModelLibrary
//
//  Created by Erik Hatfield on 4/7/25.
//

import Foundation
import Fluent
/*
 "kill_datetime": "2025-03-01 00:00:19",
 "killer_corporation_id": 1000181,
 "killer_corporation_name": "Federal Defense Union",
 "killer_alliance_name": "",
 "victim_corporation_id": 98666690,
 "victim_corporation_name": "Dirty Vagrants",
 "victim_alliance_name": "Intergalactic Space Hobos",
 "victim_ship_type_id": 670,
 "victim_ship_type_name": "Capsule",
 "victim_ship_group_name": "Capsule",
 "solarsystem_id": 30003853,
 "solarsystem_name": "Mercomesier",
 "region_id": 10000048,
 "region_name": "Placid",
 "isk_lost": 0,
 "isk_destroyed": 0,
 "bounty_claimed": ""
 */

public struct MERKillmailData: Decodable {
    public let kill_datetime: String
    public let killer_corporation_id: Int64
    public let killer_corporation_name: String
    public let killer_alliance_name: String
    public let victim_corporation_id: Int64
    public let victim_corporation_name: String
    public let victim_alliance_name: String
    public let victim_ship_type_id: Int64
    public let victim_ship_type_name: String
    public let victim_ship_group_name: String
    public let solarsystem_id: Int64
    public let solarsystem_name: String
    public let region_id: Int64
    public let region_name: String
    public let isk_lost: Double
    public let isk_destroyed: Double
}

final public class MERKillmailModel: Model, @unchecked Sendable {
    static public let schema = Schemas.Killmail.mer.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Field(key: "kill_datetime")
    public var killDatetime: String
    
    @Field(key: "killer_corporation_id")
    public var killerCorporationId: Int64
    
    @Field(key: "killer_corporation_name")
    public var killerCorporationName: String
    
    @Field(key: "killer_alliance_name")
    public var killerAllianceName: String
    
    @Field(key: "victim_corporation_id")
    public var victimCorporationId: Int64
    
    @Field(key: "victim_corporation_name")
    public var victimCorporationName: String
    
    @Field(key: "victim_alliance_name")
    public var victimAllianceName: String
    
    @Field(key: "victim_ship_type_id")
    public var victimShipTypeId: Int64
    
    @Field(key: "victim_ship_type_name")
    public var victimShipTypeName: String
    
    @Field(key: "victim_ship_group_name")
    public var victimShipGroupName: String
    
    @Field(key: "solarsystem_id")
    public var solarSystemId: Int64
    
    @Field(key: "solarsystem_name")
    public var solarSystemName: String
    
    @Field(key: "region_id")
    public var regionId: Int64
    
    @Field(key: "region_name")
    public var regionName: String
    
    @Field(key: "isk_lost")
    public var iskLost: Int64
    
    @Field(key: "isk_destroyed")
    public var iskDestroyed: Int64
    
//    @Field(key: "bounty_claimed")
//    public var bountyClaimed: Bool?
    
    public init() { }
    
    public init(
        id: UUID = UUID(),
        killDatetime: String,
        killerCorporationId: Int64,
        killerCorporationName: String,
        killerAllianceName: String,
        victimCorporationId: Int64,
        victimCorporationName: String,
        victimAllianceName: String,
        victimShipTypeId: Int64,
        victimShipTypeName: String,
        victimShipGroupName: String,
        solarSystemId: Int64,
        solarSystemName: String,
        regionId: Int64,
        regionName: String,
        iskLost: Int64,
        iskDestroyed: Int64,
        bountyClaimed: Bool? = nil
    ) {
        self.id = id
        self.killDatetime = killDatetime
        self.killerCorporationId = killerCorporationId
        self.killerCorporationName = killerCorporationName
        self.killerAllianceName = killerAllianceName
        self.victimCorporationId = victimCorporationId
        self.victimCorporationName = victimCorporationName
        self.victimAllianceName = victimAllianceName
        self.victimShipTypeId = victimShipTypeId
        self.victimShipTypeName = victimShipTypeName
        self.victimShipGroupName = victimShipGroupName
        self.solarSystemId = solarSystemId
        self.solarSystemName = solarSystemName
        self.regionId = regionId
        self.regionName = regionName
        self.iskLost = iskLost
        self.iskDestroyed = iskDestroyed
        //self.bountyClaimed = bountyClaimed
    }
    
    public convenience init(data: MERKillmailData) {
        self.init(
            killDatetime: data.kill_datetime,
            killerCorporationId: data.killer_corporation_id,
            killerCorporationName: data.killer_corporation_name,
            killerAllianceName: data.killer_alliance_name,
            victimCorporationId: data.victim_corporation_id,
            victimCorporationName: data.victim_corporation_name,
            victimAllianceName: data.victim_alliance_name,
            victimShipTypeId: data.victim_ship_type_id,
            victimShipTypeName: data.victim_ship_type_name,
            victimShipGroupName: data.victim_ship_group_name,
            solarSystemId: data.solarsystem_id,
            solarSystemName: data.solarsystem_name,
            regionId: data.region_id,
            regionName: data.region_name,
            iskLost: Int64(data.isk_lost),
            iskDestroyed: Int64(data.isk_destroyed)
        )
    }
    
    public struct ModelMigration: AsyncMigration {        
        public init() { }
        
        public func prepare(on database: any Database) async throws {
            try await database.schema(MERKillmailModel.schema)
                .id()
                .field("kill_datetime", .string, .required)
                .field("killer_corporation_id", .int64, .required)
                .field("killer_corporation_name", .string, .required)
                .field("killer_alliance_name", .string, .required)
                .field("victim_corporation_id", .int64, .required)
                .field("victim_corporation_name", .string, .required)
                .field("victim_alliance_name", .string, .required)
                .field("victim_ship_type_id", .int64, .required)
                .field("victim_ship_type_name", .string, .required)
                .field("victim_ship_group_name", .string, .required)
                .field("solarsystem_id", .int64, .required)
                .field("solarsystem_name", .string, .required)
                .field("region_id", .int64, .required)
                .field("region_name", .string, .required)
                .field("isk_lost", .int64, .required)
                .field("isk_destroyed", .int64, .required)
                .unique(on: "kill_datetime", "killer_corporation_id", "victim_corporation_id", "isk_lost")
                .create()
                
        }
        
        public func revert(on database: any Database) async throws {
            try await database.schema(MERKillmailModel.schema).delete()
        }
    }
}
