//
//  BlueprintModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/24/23.
//

import Fluent
import Foundation

public struct TimedData: Codable {
    public var time: Int64

    public init(time: Int64) {
        self.time = time
    }
}

public struct BlueprintData: Codable {
    public let activities: BlueprintActivityData
    public let blueprintTypeID: Int64
    public let maxProductionLimit: Int64
    public init(
        activities: BlueprintActivityData, blueprintTypeID: Int64,
        maxProductionLimit: Int64
    ) {
        self.activities = activities
        self.blueprintTypeID = blueprintTypeID
        self.maxProductionLimit = maxProductionLimit
    }
}

public struct BlueprintManufacturingData: Codable {
    public let materials: [QuantityTypeData]?
    public let products: [QuantityTypeData]?
    public let time: Int64

    public init(
        materials: [QuantityTypeData]?, products: [QuantityTypeData]?,
        time: Int64
    ) {
        self.materials = materials
        self.products = products
        self.time = time
    }
}

public struct QuantityTypeData: Codable {
    public let quantity: Int64
    public let typeID: Int64
    public init(quantity: Int64, typeID: Int64) {
        self.quantity = quantity
        self.typeID = typeID
    }
}

public struct BlueprintActivityData: Codable {
    public let copying: TimedData?
    public let manufacturing: BlueprintManufacturingData?
    public let reaction: BlueprintManufacturingData?
    public let research_material: TimedData?
    public let research_time: TimedData?
    public init(
        copying: TimedData?, manufacturing: BlueprintManufacturingData?,
        reaction: BlueprintManufacturingData?, research_material: TimedData?,
        research_time: TimedData?
    ) {
        self.copying = copying
        self.manufacturing = manufacturing
        self.reaction = reaction
        self.research_material = research_material
        self.research_time = research_time
    }
}

public struct Blueprint {
    public let activities: Activities
    public init(activities: Activities) {
        self.activities = activities
    }
}

public struct Activities {
    public let products: [Product]
    public init(products: [Product]) {
        self.products = products
    }
}

public struct Product {
    public let id: Int
    public let count: Int
    public init(id: Int, count: Int) {
        self.id = id
        self.count = count
    }
}

final public class BlueprintModel: Model {
    static public let schema = Schemas.blueprintModel.rawValue

    @ID(key: .id) public var id: UUID?

    @Group(key: "activities")
    public var activities: BlueprintActivityModel
    
    @Field(key: "blueprintTypeID")
    public var blueprintTypeID: Int64
    
    @Field(key: "maxProductionLimit")
    public var maxProductionLimit: Int64

    public init() {}

    public init(data: BlueprintData) {
        self.id = UUID()
        self.activities = BlueprintActivityModel(data: data.activities)
        self.blueprintTypeID = data.blueprintTypeID
        self.maxProductionLimit = data.maxProductionLimit
    }

    public struct ModelMigration: AsyncMigration {
        public init() { }
        public func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(BlueprintModel.schema)
                .id()
                .field("activities_copying_time", .int64)
                .field(
                    "activities_manufacturing_materials",
                    .array(of: .custom(QuantityTypeModel.self))
                )
                .field(
                    "activities_manufacturing_products",
                    .array(of: .custom(QuantityTypeModel.self))
                )
                .field("activities_manufacturing_time", .int64)
                .field(
                    "activities_reaction_materials",
                    .array(of: .custom(QuantityTypeModel.self))
                )
                .field(
                    "activities_reaction_products",
                    .array(of: .custom(QuantityTypeModel.self))
                )
                .field("activities_reaction_time", .int64)
                .field("activities_researching_time", .int64)
                .field("activities_researchMaterial_time", .int64)
                .field("activities_researchTime_time", .int64)
                .field("blueprintTypeID", .int64, .required)
                .field("maxProductionLimit", .int64, .required)
                .create()
        }

        public func revert(on database: FluentKit.Database) async throws {
            try await database.schema(BlueprintModel.schema)
                .delete()
        }
    }
}

final public class QuantityTypeModel: Fields {

    @Field(key: "quantity")
    public var quantity: Int64

    @Field(key: "typeId")
    public var typeId: Int64

    public init() {}

    public init(quantity: Int64, typeId: Int64) {
        self.quantity = quantity
        self.typeId = typeId
    }
}

final public class BlueprintManufacturingModel: Fields {

    @Field(key: "materials")
    public var materials: [QuantityTypeModel]

    @Field(key: "products")
    public var products: [QuantityTypeModel]

    @Field(key: "time")
    public var time: Int64

    public init() {
        self.materials = []
        self.products = []
        self.time = 0
    }
}

final public class BlueprintActivityModel: Fields {

    @Group(key: "copying")
    public var copying: TimeAmount

    @Group(key: "manufacturing")
    public var manufacturing: BlueprintManufacturingModel

    @Group(key: "reaction")
    public var reaction: BlueprintManufacturingModel

    @Group(key: "researchMaterial")
    public var researchMaterial: TimeAmount

    @Group(key: "researchTime")
    public var researchTime: TimeAmount

    public init() {}
}

extension BlueprintActivityModel {
    public convenience init(data: BlueprintActivityData) {
        self.init()
        self.copying.time = data.copying?.time ?? 0

        if let manufacturingData = data.manufacturing {
            self.manufacturing = BlueprintManufacturingModel(
                data: manufacturingData)
        } else {
            self.manufacturing = BlueprintManufacturingModel()
        }

        if let reactionData = data.reaction {
            self.reaction = BlueprintManufacturingModel(data: reactionData)
        } else {
            self.reaction = BlueprintManufacturingModel()
        }

        self.researchMaterial.time = data.research_material?.time ?? 0
        self.researchTime.time = data.research_time?.time ?? 0
    }
}

extension BlueprintManufacturingModel {
    public convenience init(data: BlueprintManufacturingData) {
        self.init()
        //self.materials = []
        self.materials =
            data.materials?.compactMap { material in
                let typeModel = QuantityTypeModel()
                typeModel.quantity = material.quantity
                typeModel.typeId = material.typeID
                return typeModel
            } ?? []

        self.products = []

        self.products =
            data.products?.compactMap({ product in
                let typeModel = QuantityTypeModel()
                typeModel.quantity = product.quantity
                typeModel.typeId = product.typeID
                return typeModel
            }) ?? []

        self.time = data.time
    }
}

final public class TimeAmount: Fields {
    @Field(key: "time")
    public var time: Int64

    public init() {}
}
