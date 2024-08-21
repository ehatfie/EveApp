//
//  DogmaAttribute.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Foundation
import Fluent
import Vapor

final public class DogmaAttributeModel: Model, Content {
    static public let schema = Schemas.dogmaAttribute.rawValue

    @ID(key: .id)
    public var id: UUID?

    @Field(key: "attributeId")
    public var attributeID: Int64

    @Field(key: "categoryId")
    public var categoryID: Int64?

    @Field(key: "dataType")
    public var dataType: Int

    @Field(key: "defaultValue")
    public var defaultValue: Double

    @Field(key: "description")
    public var attributeDescription: String?
    
    @Field(key: "displayNameID")
    public var displayNameID: String?
    
    @Field(key: "highIsGood")
    public var highIsGood: Bool

    @Field(key: "iconId")
    public var iconID: Int?

    @Field(key: "name")
    public var name: String

    @Field(key: "published")
    public var published: Bool

    @Field(key: "stackable")
    public var stackable: Bool

    @Field(key: "tooltipDescriptionId")
    public var tooltipDescriptionID: String?

    @Field(key: "tooltipTitleId")
    public var tooltipTitleID: String?

    @Field(key: "unitId")
    public var unitID: Int?

    public init() {}

    public init(id: UUID? = nil, attributeID: Int64, categoryID: Int64?, dataType: Int, defaultValue: Double, description: String?, displayNameID: String?, highIsGood: Bool, iconID: Int?, name: String, published: Bool, stackable: Bool, tooltipDescriptionID: String?, tooltipTitleID: String?, unitID: Int?) {
        self.id = id
        self.attributeID = attributeID
        self.categoryID = categoryID
        self.dataType = dataType
        self.defaultValue = defaultValue
        self.attributeDescription = description
        self.displayNameID = displayNameID
        self.highIsGood = highIsGood
        self.iconID = iconID
        self.name = name
        self.published = published
        self.stackable = stackable
        self.tooltipDescriptionID = tooltipDescriptionID
        self.tooltipTitleID = tooltipTitleID
        self.unitID = unitID
    }
    
    public init(attributeId: Int64, data: DogmaAttributeData1) {
        self.id = UUID()
        self.attributeID = data.attributeID
        self.categoryID = data.categoryID
        self.dataType = data.dataType
        self.defaultValue = data.defaultValue
        self.attributeDescription = data.description
        self.displayNameID = data.displayNameID?.en
        self.highIsGood = data.highIsGood
        self.iconID = data.iconID
        self.name = data.name
        self.published = data.published
        self.stackable = data.stackable
        self.tooltipDescriptionID = data.tooltipDescriptionID?.en ?? ""
        self.tooltipTitleID = data.tooltipTitleID?.en ?? ""
        self.unitID = data.unitID
    }
}

public struct CreateDogmaAttributeModelMigration: Migration {
    public init() { }
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DogmaAttributeModel.schema)
            .id()
            .field("attributeId", .int, .required)
            .field("categoryId", .int)
            .field("dataType", .int, .required)
            .field("defaultValue", .double, .required)
            .field("description", .string)
            .field("displayNameID", .string)
            .field("highIsGood", .bool, .required)
            .field("iconId", .int)
            .field("name", .string, .required)
            .field("published", .bool, .required)
            .field("stackable", .bool, .required)
            .field("tooltipDescriptionId", .string)
            .field("tooltipTitleId", .string)
            .field("unitId", .int)
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DogmaAttributeModel.schema).delete()
    }
}

public struct DogmaAttributeData1: Codable {
    public let attributeID: Int64
    public let categoryID: Int64?
    public let dataType: Int
    public let defaultValue: Double
    public let description: String?
    public let displayNameID: ThingName?
    public let highIsGood: Bool
    public let iconID: Int?
    public let name: String
    public let published: Bool
    public let stackable: Bool
    public let tooltipDescriptionID: ThingName?
    public let tooltipTitleID: ThingName?
    public let unitID: Int?
    
    public init(attributeID: Int64,
         categoryID: Int64? = nil,
         dataType: Int = 0,
         defaultValue: Double,
         description: String?,
         displayNameID: ThingName? = nil,
         highIsGood: Bool = true,
         iconID: Int? = nil,
         name: String,
         published: Bool = false,
         stackable: Bool = false,
         tooltipDescriptionID: ThingName? = nil,
         tooltipTitleID: ThingName? = nil,
         unitID: Int? = nil
    ) {
        self.attributeID = attributeID
        self.categoryID = categoryID
        self.dataType = dataType
        self.defaultValue = defaultValue
        self.description = description
        self.displayNameID = displayNameID
        self.highIsGood = highIsGood
        self.iconID = iconID
        self.name = name
        self.published = published
        self.stackable = stackable
        self.tooltipDescriptionID = tooltipDescriptionID
        self.tooltipTitleID = tooltipTitleID
        self.unitID = unitID
    }
}
