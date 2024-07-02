//
//  DogmaAttribute.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Foundation
import Fluent
import Vapor

final class DogmaAttributeModel: Model, Content {
    static let schema = Schemas.dogmaAttribute.rawValue

    @ID(key: .id)
    var id: UUID?

    @Field(key: "attributeId")
    var attributeID: Int64

    @Field(key: "categoryId")
    var categoryID: Int64?

    @Field(key: "dataType")
    var dataType: Int

    @Field(key: "defaultValue")
    var defaultValue: Double

    @Field(key: "description")
    var attributeDescription: String?
    
    @Field(key: "displayNameID")
    var displayNameID: String?
    
    @Field(key: "highIsGood")
    var highIsGood: Bool

    @Field(key: "iconId")
    var iconID: Int?

    @Field(key: "name")
    var name: String

    @Field(key: "published")
    var published: Bool

    @Field(key: "stackable")
    var stackable: Bool

    @Field(key: "tooltipDescriptionId")
    var tooltipDescriptionID: String?

    @Field(key: "tooltipTitleId")
    var tooltipTitleID: String?

    @Field(key: "unitId")
    var unitID: Int?

    init() {}

    init(id: UUID? = nil, attributeID: Int64, categoryID: Int64?, dataType: Int, defaultValue: Double, description: String?, displayNameID: String?, highIsGood: Bool, iconID: Int?, name: String, published: Bool, stackable: Bool, tooltipDescriptionID: String?, tooltipTitleID: String?, unitID: Int?) {
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
    
    init(attributeId: Int64, data: DogmaAttributeData1) {
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

struct CreateDogmaAttributeModelMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
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

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DogmaAttributeModel.schema).delete()
    }
}

struct DogmaAttributeData1: Codable {
    let attributeID: Int64
    let categoryID: Int64?
    let dataType: Int
    let defaultValue: Double
    let description: String?
    let displayNameID: ThingName?
    let highIsGood: Bool
    let iconID: Int?
    let name: String
    let published: Bool
    let stackable: Bool
    let tooltipDescriptionID: ThingName?
    let tooltipTitleID: ThingName?
    let unitID: Int?
    
    init(attributeID: Int64,
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
