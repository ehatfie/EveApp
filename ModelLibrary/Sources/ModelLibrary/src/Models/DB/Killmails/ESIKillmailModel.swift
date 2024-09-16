//
//  ESIKillmailModel.swift
//  ModelLibrary
//
//  Created by Erik Hatfield on 9/10/24.
//

import Foundation
import FluentSQLiteDriver
import TestPackage3

final public class ESIKillmailModel: Model {
    static public let schema = Schemas.Killmail.esi.rawValue
    //@Field(key: "skills") public var skills: [CharacterSkillModel]
    @ID(key: .id) public var id: UUID?
    @Field(key: "attackers") public var attackers: [ESIKmAttacker]
    @Field(key: "killmail_id") public var killmailId: Int64
    @Field(key: "killmail_time") public var killmailTime: String
    @Field(key: "moon_id") public var moonId: Int64?
    @Field(key: "solar_system_id") public var solarSystemId: Int64
    @Field(key: "victim") public var victim: [ESIKmVictim]
    @Field(key: "war_id") public var warId: Int64?
    
    public init() { }
    
    public init(
        id: UUID = UUID(),
        attackers: [ESIKmAttacker],
        killmailId: Int64,
        killmailTime: String,
        moonId: Int64? = nil,
        solarSystemId: Int64,
        victim: ESIKmVictim,
        warId: Int64? = nil
    ) {
        self.id = id
        self.attackers = attackers
        self.killmailId = killmailId
        self.killmailTime = killmailTime
        self.moonId = moonId
        self.solarSystemId = solarSystemId
        self.victim = [victim]
        self.warId = warId
    }
    
    public convenience init(data: EveKmData) {
        self.init(
            attackers: data.attackers.map { ESIKmAttacker(data: $0)},
            killmailId: data.killmail_id,
            killmailTime: data.killmail_time,
            moonId: data.moon_id,
            solarSystemId: data.solar_system_id,
            victim: ESIKmVictim(data: data.victim),
            warId: data.war_id
        )
    }
    
    public struct ModelMigration: AsyncMigration {
        public init() { }
        
        public func prepare(on database: Database) async throws {
            try await database.schema(ESIKillmailModel.schema)
                .id()
                .field("attackers", .array(of: .custom(ESIKmAttacker.self)), .required)
                .field("killmail_id", .int64, .required)
                .field("killmail_time", .string, .required)
                .field("moon_id", .int64)
                .field("solar_system_id", .int64, .required)
                .field("victim", .array(of: .custom(ESIKmVictim.self)), .required)
                .field("war_id", .int64)
                .unique(on: "killmail_id")
                .create()
        }
        
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(ESIKillmailModel.schema)
                .delete()
        }
    }
}



final public class ESIKmAttacker: Fields {
    @Field(key: "alliance_id") public var allianceId: Int64?
    @Field(key: "character_id") public var characterId: Int64?
    @Field(key: "corporation_id") public var corporationId: Int64?
    @Field(key: "damage_done") public var damageDone: Int64
    @Field(key: "faction_id") public var factionId: Int64?
    @Field(key: "final_blow") public var finalBlow: Bool
    @Field(key: "security_status") public var securityStatus: Float
    @Field(key: "ship_type_id") public var shipTypeId: Int64?
    @Field(key: "weapon_type_id") public var weaponTypeId: Int64?
    
    public init() { }
    
    public init(
        allianceId: Int64? = nil,
        characterId: Int64? = nil,
        corporationId: Int64? = nil,
        damageDone: Int64,
        factionId: Int64? = nil,
        finalBlow: Bool,
        securityStatus: Float,
        shipTypeId: Int64? = nil,
        weaponTypeId: Int64? = nil
    ) {
        self.allianceId = allianceId
        self.characterId = characterId
        self.corporationId = corporationId
        self.damageDone = damageDone
        self.factionId = factionId
        self.finalBlow = finalBlow
        self.securityStatus = securityStatus
        self.shipTypeId = shipTypeId
        self.weaponTypeId = weaponTypeId
    }
    
    public convenience init(data: EveKmAttackerData) {
        self.init(
            allianceId: data.alliance_Id,
            characterId: data.character_id,
            corporationId: data.corporation_id,
            damageDone: data.damage_done,
            factionId: data.faction_id,
            finalBlow: data.final_blow,
            securityStatus: data.security_status,
            shipTypeId: data.ship_type_id,
            weaponTypeId: data.weapon_type_id
        )
    }
}

final public class ESIKmVictim: Fields {
    @Field(key: "alliance_id_v") public var allianceId1: Int64
    @Field(key: "character_id_v") public var characterId: Int64?
    @Field(key: "corporation_id_v") public var corporationId: Int64?
    @Field(key: "damage_taken_v") public var damageTaken: Int64
    @Field(key: "faction_id_v") public var factionId: Int64?
    @Field(key: "items") public var items: [ESIKmVictimItems]
    @Field(key: "ship_type_id_v") public var shipTypeId: Int64?
    
    public init() { }
    
    public init(
        allianceId: Int64,
        characterId: Int64? = nil,
        corporationId: Int64? = nil,
        damageTaken: Int64,
        factionId: Int64? = nil,
        items: [ESIKmVictimItems],
        shipTypeId: Int64? = nil
    ) {
        self.allianceId1 = allianceId
        self.characterId = characterId
        self.corporationId = corporationId
        self.damageTaken = damageTaken
        self.factionId = factionId
        self.items = items
        self.shipTypeId = shipTypeId
    }
    
    public convenience init(data: EveKmVictimData) {
        self.init(
            allianceId: data.alliance_Id ?? -1,
            characterId: data.character_id,
            corporationId: data.corporation_id,
            damageTaken: data.damage_taken,
            factionId: data.faction_id,
            items: (data.items ?? []).map { ESIKmVictimItems(data: $0)},
            shipTypeId: data.ship_type_id
        )
    }
}

final public class ESIKmVictimItems: Fields {
    @Field(key: "item_flag") public var itemFlag: Int64
    @Field(key: "item_type_id") public var itemTypeId: Int64
    @Field(key: "items") public var items: [ESIKmVictimItems]
    @Field(key: "quantity_destroyed") public var quantityDestroyed: Int64?
    @Field(key: "quantity_dropped") public var quantityDropped: Int64?
    @Field(key: "singleton") public var singleton: Int64
    
    public init() { }
    
    public init(
        flag: Int64,
        itemTypeId: Int64,
        items: [ESIKmVictimItems],
        quantityDestroyed: Int64?,
        quantityDropped: Int64?,
        singleton: Int64
    ) {
        self.itemFlag = flag
        self.itemTypeId = itemTypeId
        self.items = items
        self.quantityDestroyed = quantityDestroyed
        self.quantityDropped = quantityDropped
        self.singleton = singleton
    }
    
    convenience init(data: EveKmVictimItemsData) {
        self.init(
            flag: data.flag,
            itemTypeId: data.item_type_id,
            items: (data.items ?? []).map { ESIKmVictimItems(data: $0)},
            quantityDestroyed: data.quantity_destroyed,
            quantityDropped: data.quantity_dropped,
            singleton: data.singleton
        )
    }
}

/*
 public struct EveKmData: Codable {
     public let attackers: [EveKmAttackerData]
     public let killmail_id: Int32
     public let killmail_time: String
     public let moon_id: Int32?
     public let solar_system_id: Int32
     public let victim: EveKmVictimData
     public let war_id: Int32?
 }

 */

/*
 public struct EveKmAttackerData: Codable {
     public let alliance_Id: Int32?
     public let character_id: Int32?
     public let corporation_id: Int32?
     public let damage_done: Int32
     public let faction_id: Int32?
     public let final_blow: Bool
     public let security_status: Float
     public let ship_type_id: Int32?
     public let weapon_type_id: Int32?
 }
 */
