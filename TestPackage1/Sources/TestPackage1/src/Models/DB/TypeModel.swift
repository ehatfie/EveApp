//
//  TypeModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Foundation
import Fluent
import Vapor

public struct TypeData: Codable {
    public let capacity: Double?
    public let description: ThingName?
    public let graphicID: Int?
    public let groupID: Int64?
    public let iconID: Int?
    public let marketGroupID: Int?
    public let mass: Double?
    public let metaGroupID: Int?
    public let name: ThingName?
    public let portionSize: Int?
    public let published: Bool
    public let variationParentTypeID: Int?
    public let radius: Double?
    public let raceID: Int?
    public let sofFactionName: String?
    public let soundID: Int?
    public let volume: Double?
    
    public init(capacity: Double? = nil, description: ThingName? = nil, graphicID: Int? = nil, groupID: Int64?, iconID: Int? = nil, marketGroupID: Int? = nil, mass: Double? = nil, metaGroupID: Int? = nil, name: ThingName? = nil, portionSize: Int? = nil, published: Bool, variationParentTypeID: Int? = nil, radius: Double? = nil, raceID: Int? = nil, sofFactionName: String? = nil, soundID: Int? = nil, volume: Double? = nil)
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

final public class TypeModel: Model, Content {
    public static let schema = "TypeData"

    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "typeId")
    public var typeId: Int64

    @Field(key: "capacity")
    public var capacity: Double?

    @Field(key: "description")
    public var descriptionString: String?

    @Field(key: "graphic_id")
    public var graphicID: Int?

    @Field(key: "group_id")
    public var groupID: Int64

    @Field(key: "icon_id")
    public var iconID: Int?

    @Field(key: "market_group_id")
    public var marketGroupID: Int?

    @Field(key: "mass")
    public var mass: Double?

    @Field(key: "meta_group_id")
    public var metaGroupID: Int?

    @Field(key: "name")
    public var name: String

    @Field(key: "portion_size")
    public var portionSize: Int?

    @Field(key: "published")
    public var published: Bool

    @Field(key: "variation_parent_type_id")
    public var variationParentTypeID: Int?

    @Field(key: "radius")
    public var radius: Double?

    @Field(key: "race_id")
    public var raceID: Int?

    @Field(key: "sof_faction_name")
    public var sofFactionName: String?

    @Field(key: "sound_id")
    public var soundID: Int?

    @Field(key: "volume")
    public var volume: Double?

    public init() {}

    public init(
        typeId: Int64,
        data: TypeData
    ) {
        self.id = UUID()
        self.typeId = typeId
        self.capacity = data.capacity
        self.descriptionString = data.description?.en
        self.graphicID = data.graphicID
        self.groupID = data.groupID ?? -1
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


public struct CreateTypeModelMigration: Migration {
    public init() { }
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
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

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TypeModel.schema).delete()
    }
}
