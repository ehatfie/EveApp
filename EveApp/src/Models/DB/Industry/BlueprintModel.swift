//
//  BlueprintModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/24/23.
//

import Foundation
import Fluent

struct TimedData: Codable {
  var time: Int64
}

struct BlueprintData: Codable {
  let activities: BlueprintActivityData
  let blueprintTypeID: Int64
  let maxProductionLimit: Int64
}

struct BlueprintManufacturingData:Codable {
  let materials: [QuantityTypeData]?
  let products: [QuantityTypeData]?
  let time: Int64
}

struct QuantityTypeData: Codable {
  let quantity: Int64
  let typeID: Int64
}

struct BlueprintActivityData: Codable {
  let copying: TimedData?
  let manufacturing: BlueprintManufacturingData?
  let research_material: TimedData?
  let research_time: TimedData?
}


final class BlueprintModel: Model {
  static let schema = Schemas.blueprintModel.rawValue
  
  @ID(key: .id) var id: UUID?
  
  @Group(key: "activities") var activities: BlueprintActivityModel
  @Field(key: "blueprintTypeID") var blueprintTypeID: Int64
  @Field(key: "maxProductionLimit") var maxProductionLimit: Int64
  
  init() { }
  
  init(data: BlueprintData) {
    self.id = UUID()
    self.activities = BlueprintActivityModel(data: data.activities)
    self.blueprintTypeID = data.blueprintTypeID
    self.maxProductionLimit = data.maxProductionLimit
  }
  
  struct ModelMigration: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
      database.schema(BlueprintModel.schema)
        .id()
        .field("activities_copying_time", .int64)
        .field("activities_manufacturing_materials", .array(of: .custom(QuantityTypeModel.self)))
//        .field("activities_manufacturing_materials_quantity", .array(of: .json))
        //.field("activities_manufacturing_materials_typeID", .int64)
        //.field("activities_manufacturing_products_quantity", .int64)
        //.field("activities_manufacturing_products_typeID", .int64)
        .field("activities_manufacturing_products", .array(of: .custom(QuantityTypeModel.self)))
        .field("activities_manufacturing_time", .int64)
        .field("activities_researching_time", .int64)
        .field("activities_researchMaterial_time", .int64)
        .field("activities_researchTime_time", .int64)
        .field("blueprintTypeID", .int64, .required)
        .field("maxProductionLimit", .int64, .required)
        .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
      database.schema(TypeMaterialsModel.schema)
        .delete()
    }
  }
}


final class QuantityTypeModel: Fields {
  
    @Field(key: "quantity")
    var quantity: Int64

    @Field(key: "typeId")
    var typeId: Int64

    
    init() { }
}

final class BlueprintManufacturingModel: Fields {
  
  @Field(key: "materials")
  var materials: [QuantityTypeModel]
  
  @Field(key: "products")
  var products: [QuantityTypeModel]
  
  @Field(key: "time")
  var time: Int64
  
  init() {
    self.materials = []
    self.products = []
    self.time = 0
  }
}

final class BlueprintActivityModel: Fields {
  
  @Group(key: "copying")
  var copying: TimeAmount
  
  @Group(key: "manufacturing")
  var manufacturing: BlueprintManufacturingModel
  
  @Group(key: "researchMaterial")
  var researchMaterial: TimeAmount
  
  @Group(key: "researchTime")
  var researchTime: TimeAmount
}

extension BlueprintActivityModel {
  convenience init(data: BlueprintActivityData) {
    self.init()
    self.copying.time = data.copying?.time ?? 0
    
    if let manufacturingData = data.manufacturing {
      self.manufacturing = BlueprintManufacturingModel(data: manufacturingData)
    } else {
      self.manufacturing = BlueprintManufacturingModel()
    }
    
    self.researchMaterial.time = data.research_material?.time ?? 0
    self.researchTime.time = data.research_time?.time ?? 0
  }
}

extension BlueprintManufacturingModel {
  convenience init(data: BlueprintManufacturingData) {
    self.init()
    //self.materials = []
    self.materials = data.materials?.compactMap { material in
      let typeModel = QuantityTypeModel()
      typeModel.quantity = material.quantity
      typeModel.typeId = material.typeID
      return typeModel
    } ?? []
    
    self.products = []
    
    self.products = data.products?.compactMap({ product in
      let typeModel = QuantityTypeModel()
      typeModel.quantity = product.quantity
      typeModel.typeId = product.typeID
      return typeModel
    }) ?? []
    
    self.time = data.time
  }
}

final class TimeAmount: Fields {
  @Field(key: "time")
  var time: Int64
}

