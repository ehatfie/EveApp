//
//  TypeModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Foundation
import Fluent
import Vapor

struct TypeData: Codable {
    let capacity: Double?
    let description: ThingName?
    let graphicID: Int?
    let groupID: Int64
    let iconID: Int?
    let marketGroupID: Int?
    let mass: Double?
    let metaGroupID: Int?
    let name: ThingName?
    let portionSize: Int
    let published: Bool
    let variationParentTypeID: Int?
    let radius: Double?
    let raceID: Int?
    let sofFactionName: String?
    let soundID: Int?
    let volume: Double?
    
    init(capacity: Double? = nil, description: ThingName? = nil, graphicID: Int? = nil, groupID: Int64, iconID: Int? = nil, marketGroupID: Int? = nil, mass: Double? = nil, metaGroupID: Int? = nil, name: ThingName? = nil, portionSize: Int, published: Bool, variationParentTypeID: Int? = nil, radius: Double? = nil, raceID: Int? = nil, sofFactionName: String? = nil, soundID: Int? = nil, volume: Double? = nil)
    {
        self.capacity = capacity
        self.description = description
        self.graphicID = graphicID
        self.groupID = groupID
        self.iconID = iconID
        self.marketGroupID = marketGroupID
        self.mass = mass
        self.metaGroupID = metaGroupID
        self.name = name
        self.portionSize = portionSize
        self.published = published
        self.variationParentTypeID = variationParentTypeID
        self.radius = radius
        self.raceID = raceID
        self.sofFactionName = sofFactionName
        self.soundID = soundID
        self.volume = volume
    }
}

final class TypeModel: Model, Content {
    static let schema = "TypeData"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "typeId")
    var typeId: Int64

    @Field(key: "capacity")
    var capacity: Double?

    @Field(key: "description")
    var description: String?

    @Field(key: "graphic_id")
    var graphicID: Int?

    @Field(key: "group_id")
    var groupID: Int64

    @Field(key: "icon_id")
    var iconID: Int?

    @Field(key: "market_group_id")
    var marketGroupID: Int?

    @Field(key: "mass")
    var mass: Double?

    @Field(key: "meta_group_id")
    var metaGroupID: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "portion_size")
    var portionSize: Int

    @Field(key: "published")
    var published: Bool

    @Field(key: "variation_parent_type_id")
    var variationParentTypeID: Int?

    @Field(key: "radius")
    var radius: Double?

    @Field(key: "race_id")
    var raceID: Int?

    @Field(key: "sof_faction_name")
    var sofFactionName: String?

    @Field(key: "sound_id")
    var soundID: Int?

    @Field(key: "volume")
    var volume: Double?

    init() {}

    init(
        typeId: Int64,
        data: TypeData
    ) {
        self.id = UUID()
        self.typeId = typeId
        self.capacity = data.capacity
        self.description = data.description?.en
        self.graphicID = data.graphicID
        self.groupID = data.groupID
        self.iconID = data.iconID
        self.marketGroupID = data.marketGroupID
        self.mass = data.mass
        self.metaGroupID = data.metaGroupID
        self.name = data.name?.en ?? ""
        self.portionSize = data.portionSize
        self.published = data.published
        self.variationParentTypeID = data.variationParentTypeID
        self.radius = data.radius
        self.raceID = data.raceID
        self.sofFactionName = data.sofFactionName
        self.soundID = data.soundID
        self.volume = data.volume
    }
}


struct CreateTypeModelMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TypeModel.schema)
            .id()
            .field("typeId", .int64)
            .field("capacity", .double)
            .field("description", .string)
            .field("graphic_id", .int)
            .field("group_id", .int)
            .field("icon_id", .int)
            .field("market_group_id", .int)
            .field("mass", .double)
            .field("meta_group_id", .int)
            .field("name", .string, .required)
            .field("portion_size", .int)
            .field("published", .bool)
            .field("variation_parent_type_id", .int)
            .field("radius", .double)
            .field("race_id", .int)
            .field("sof_faction_name", .string)
            .field("sound_id", .int)
            .field("volume", .double)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TypeModel.schema).delete()
    }
}
