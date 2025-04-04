//
//  DogmaEffect.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Fluent
import Vapor

final public class DogmaEffectModel: Model, Content, @unchecked Sendable {
    static public let schema = Schemas.dogmaEffect.rawValue

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "description_id")
    public var descriptionID: String?

    @Field(key: "disallow_auto_repeat")
    public var disallowAutoRepeat: Bool

    @Field(key: "display_name_id")
    public var displayNameID: String?

    @Field(key: "discharge_attribute_id")
    public var dischargeAttributeID: Int64?

    @Field(key: "distribution")
    public var distribution: Int64?

    @Field(key: "duration_attribute_id")
    public var durationAttributeID: Int64?

    @Field(key: "effect_category")
    public var effectCategory: Int64

    @Field(key: "effect_id")
    public var effectID: Int64

    @Field(key: "effect_name")
    public var effectName: String

    @Field(key: "electronic_chance")
    public var electronicChance: Bool

    @Field(key: "guid")
    public var guid: String?

    @Field(key: "icon_id")
    public var iconID: Int?

    @Field(key: "is_assistance")
    public var isAssistance: Bool

    @Field(key: "is_offensive")
    public var isOffensive: Bool

    @Field(key: "is_warp_safe")
    public var isWarpSafe: Bool
    
    @Field(key: "modifier_info")
    public var modifierInfo: [ModifierInfo]

    @Field(key: "propulsion_chance")
    public var propulsionChance: Bool

    @Field(key: "published")
    public var published: Bool

    @Field(key: "range_chance")
    public var rangeChance: Bool

    public init() {}

    
    public init(dogmaEffectId: Int64, dogmaEffectData: DogmaEffectData) {
        descriptionID = dogmaEffectData.descriptionID?.en
        disallowAutoRepeat = dogmaEffectData.disallowAutoRepeat
        displayNameID = dogmaEffectData.displayNameID?.en
        dischargeAttributeID = dogmaEffectData.dischargeAttributeID
        distribution = dogmaEffectData.distribution
        durationAttributeID = dogmaEffectData.durationAttributeID
        effectCategory = dogmaEffectData.effectCategory
        effectID = dogmaEffectData.effectID
        effectName = dogmaEffectData.effectName
        electronicChance = dogmaEffectData.electronicChance
        guid = dogmaEffectData.guid
        iconID = dogmaEffectData.iconID
        isAssistance = dogmaEffectData.isAssistance
        isOffensive = dogmaEffectData.isOffensive
        isWarpSafe = dogmaEffectData.isWarpSafe
        self.modifierInfo = (dogmaEffectData.modifierInfo ?? []).map { ModifierInfo($0)}
        propulsionChance = dogmaEffectData.propulsionChance
        published = dogmaEffectData.published
        rangeChance = dogmaEffectData.rangeChance
    }
}

public struct CreateDogmaEffectModelMigration: Migration {
    public init() { }
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DogmaEffectModel.schema)
            .id()
            .field("description_id", .string)
            .field("disallow_auto_repeat", .bool)
            .field("display_name_id", .string)
            .field("discharge_attribute_id", .int)
            .field("distribution", .int)
            .field("duration_attribute_id", .int)
            .field("effect_category", .int)
            .field("effect_id", .int)
            .field("effect_name", .string)
            .field("electronic_chance", .bool)
            .field("guid", .string)
            .field("icon_id", .int)
            .field("is_assistance", .bool)
            .field("is_offensive", .bool)
            .field("is_warp_safe", .bool)
            .field("modifier_info", .array(of: .json))
            .field("propulsion_chance", .bool)
            .field("published", .bool)
            .field("range_chance", .bool)
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DogmaEffectModel.schema).delete()
    }
}

final public class ModifierInfo: Fields, @unchecked Sendable {
    @Field(key: "domain")
    public var domain: String
    
    @Field(key: "function")
    public var function: String
    
    @Field(key: "modified_attribute_id")
    public var modifiedAttributeID: Int64
    
    @Field(key: "modifying_attribute_id")
    public var modifiyingAttributeID: Int64
    
    @Field(key: "operation")
    public var operation: Int64
    
    @Field(key: "skill_type_id")
    public var skillTypeID: Int64
    
    public init() {
        
    }
    
    public init(_ modifierData: ModifierData) {
        self.domain = modifierData.domain
        self.function = modifierData.func
        self.modifiedAttributeID = modifierData.modifiedAttributeID ?? -1
        self.modifiyingAttributeID = modifierData.modifyingAttributeID ?? -1
        self.operation = modifierData.operation ?? -1
        self.skillTypeID = modifierData.skillTypeID ?? -1
    }
}

public struct DogmaEffectData: Codable {
    public let descriptionID: ThingName?
    public let disallowAutoRepeat: Bool
    public let displayNameID: ThingName?
    public let dischargeAttributeID: Int64?
    public let distribution: Int64?
    public let durationAttributeID: Int64?
    public let effectCategory: Int64
    public let effectID: Int64
    public let effectName: String
    public let electronicChance: Bool
    public let guid: String?
    public let iconID: Int?
    public let isAssistance: Bool
    public let isOffensive: Bool
    public let isWarpSafe: Bool
    public let modifierInfo: [ModifierData]?
    public let propulsionChance: Bool
    public let published: Bool
    public let rangeChance: Bool
}


public struct ModifierData: Codable {
    public let domain: String
    public let `func`: String
    public let modifiedAttributeID: Int64?
    public let modifyingAttributeID: Int64?
    public let operation: Int64?
    public let skillTypeID: Int64?
    
//    enum CodingKeys: String, CodingKey {
//        case domain, name, `func`, modifiedAttributeId, modifyingAttributeID, operation, skillTypeID
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        id = try container.decode(String.self, forKey: .id)
//        name = (try? container.decode(String.self, forKey: .name)) ?? "Default Value"
//    }
    //public var LocationRequiredSkillModifier: () -> Void
}
