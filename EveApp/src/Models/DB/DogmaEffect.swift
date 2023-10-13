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
    var dischargeAttributeID: Int?

    @Field(key: "distribution")
    var distribution: Int?

    @Field(key: "durationAttributeId")
    var durationAttributeID: Int?

    @Field(key: "effectCategory")
    var effectCategory: Int

    @Field(key: "effectId")
    var effectID: Int

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
            .field("propulsionChance", .bool)
            .field("published", .bool)
            .field("rangeChance", .bool)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DogmaEffectModel.schema).delete()
    }
}

struct DogmaEffectData: Codable {
    let descriptionID: ThingName?
    let disallowAutoRepeat: Bool
    let displayNameID: ThingName?
    let dischargeAttributeID: Int?
    let distribution: Int?
    let durationAttributeID: Int?
    let effectCategory: Int
    let effectID: Int
    let effectName: String
    let electronicChance: Bool
    let guid: String?
    let iconID: Int?
    let isAssistance: Bool
    let isOffensive: Bool
    let isWarpSafe: Bool
    let propulsionChance: Bool
    let published: Bool
    let rangeChance: Bool
}
