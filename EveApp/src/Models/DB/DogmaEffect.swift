//
//  DogmaEffect.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Fluent
import Vapor

final class DogmaEffectModel: Model, Content {
    static let schema = Schemas.dogmaEffect.rawValue

    @ID(key: .id)
    var id: UUID?

    @Field(key: "descriptionId")
    var descriptionID: String?

    @Field(key: "disallowAutoRepeat")
    var disallowAutoRepeat: Bool

    @Field(key: "displayNameId")
    var displayNameID: String?

    @Field(key: "dischargeAttributeId")
    var dischargeAttributeID: Int64?

    @Field(key: "distribution")
    var distribution: Int64?

    @Field(key: "durationAttributeId")
    var durationAttributeID: Int64?

    @Field(key: "effectCategory")
    var effectCategory: Int64

    @Field(key: "effectId")
    var effectID: Int64

    @Field(key: "effectName")
    var effectName: String

    @Field(key: "electronicChance")
    var electronicChance: Bool

    @Field(key: "guid")
    var guid: String?

    @Field(key: "iconId")
    var iconID: Int?

    @Field(key: "isAssistance")
    var isAssistance: Bool

    @Field(key: "isOffensive")
    var isOffensive: Bool

    @Field(key: "isWarpSafe")
    var isWarpSafe: Bool
    
    @Field(key: "modifierInfo")
    var modifierInfo: [ModifierInfo]

    @Field(key: "propulsionChance")
    var propulsionChance: Bool

    @Field(key: "published")
    var published: Bool

    @Field(key: "rangeChance")
    var rangeChance: Bool

    init() {}

    
    init(dogmaEffectId: Int64, dogmaEffectData: DogmaEffectData) {
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

struct CreateDogmaEffectModelMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DogmaEffectModel.schema)
            .id()
            .field("descriptionId", .string)
            .field("disallowAutoRepeat", .bool)
            .field("displayNameId", .string)
            .field("dischargeAttributeId", .int)
            .field("distribution", .int)
            .field("durationAttributeId", .int)
            .field("effectCategory", .int)
            .field("effectId", .int)
            .field("effectName", .string)
            .field("electronicChance", .bool)
            .field("guid", .string)
            .field("iconId", .int)
            .field("isAssistance", .bool)
            .field("isOffensive", .bool)
            .field("isWarpSafe", .bool)
            .field("modifierInfo", .array(of: .custom(ModifierInfo.self)))
            .field("propulsionChance", .bool)
            .field("published", .bool)
            .field("rangeChance", .bool)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DogmaEffectModel.schema).delete()
    }
}

final class ModifierInfo: Fields {
    @Field(key: "domain")
    var domain: String
    
    @Field(key: "function")
    var function: String
    
    @Field(key: "modifiedAttributeID")
    var modifiedAttributeID: Int64
    
    @Field(key: "modifyingAttributeID")
    var modifiyingAttributeID: Int64
    
    @Field(key: "operation")
    var operation: Int64
    
    @Field(key: "skillTypeID")
    var skillTypeID: Int64
    
    init() {
        
    }
    
    init(_ modifierData: ModifierData) {
        self.domain = modifierData.domain
        self.function = modifierData.func
        self.modifiedAttributeID = modifierData.modifiedAttributeID ?? -1
        self.modifiyingAttributeID = modifierData.modifyingAttributeID ?? -1
        self.operation = modifierData.operation ?? -1
        self.skillTypeID = modifierData.skillTypeID ?? -1
    }
}

struct DogmaEffectData: Codable {
    let descriptionID: ThingName?
    let disallowAutoRepeat: Bool
    let displayNameID: ThingName?
    let dischargeAttributeID: Int64?
    let distribution: Int64?
    let durationAttributeID: Int64?
    let effectCategory: Int64
    let effectID: Int64
    let effectName: String
    let electronicChance: Bool
    let guid: String?
    let iconID: Int?
    let isAssistance: Bool
    let isOffensive: Bool
    let isWarpSafe: Bool
    let modifierInfo: [ModifierData]?
    let propulsionChance: Bool
    let published: Bool
    let rangeChance: Bool
}


struct ModifierData: Codable {
    let domain: String
    let `func`: String
    let modifiedAttributeID: Int64?
    let modifyingAttributeID: Int64?
    let operation: Int64?
    let skillTypeID: Int64?
    
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
    //var LocationRequiredSkillModifier: () -> Void
}
