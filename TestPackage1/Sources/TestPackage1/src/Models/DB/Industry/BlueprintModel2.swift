//
//  BlueprintModel2.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/30/23.
//


import Foundation
import Fluent

final public  class BlueprintModel1: Model {
  static public let schema = Schemas.blueprintModel.rawValue
  
  @ID(key: .id) public var id: UUID?
  
  @Group(key: "activities") public var activities: BlueprintActivityModel
  @Field(key: "blueprintTypeID") public var blueprintTypeID: Int64
  @Field(key: "maxProductionLimit") public var maxProductionLimit: Int64
  
    public init() { }
  
    public init(data: BlueprintData) {
    self.id = UUID()
    self.activities = BlueprintActivityModel(data: data.activities)
    self.blueprintTypeID = data.blueprintTypeID
    self.maxProductionLimit = data.maxProductionLimit
  }
  
    public struct ModelMigration: Migration {
        public func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
      database.schema(BlueprintModel.schema)
        .id()
        .field("activities_copying_time", .int64)
        .field("activities_manufacturing_materials", .array(of: .custom(QuantityTypeModel.self)))
        .field("activities_manufacturing_products", .array(of: .custom(QuantityTypeModel.self)))
        .field("activities_manufacturing_time", .int64)
        .field("activities_researching_time", .int64)
        .field("activities_researchMaterial_time", .int64)
        .field("activities_researchTime_time", .int64)
        .field("blueprintTypeID", .int64, .required)
        .field("maxProductionLimit", .int64, .required)
        .create()
    }
    
        public func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
      database.schema(TypeMaterialsModel.schema)
        .delete()
    }
  }
}


final public  class QuantityTypeModel1: Fields {
  
    @Field(key: "quantity")
    public var quantity: Int64

    @Field(key: "typeId")
    public var typeId: Int64

    
    public  init() { }
}

final public class BlueprintManufacturingModel1: Fields {
  
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

final public class BlueprintActivityModel1: Fields {
  
  @Group(key: "copying")
    public var copying: TimeAmount
  
  @Group(key: "manufacturing")
    public var manufacturing: BlueprintManufacturingModel
  
  @Group(key: "researchMaterial")
    public var researchMaterial: TimeAmount
  
  @Group(key: "researchTime")
    public var researchTime: TimeAmount
    
    public init() {
        
    }
}

extension BlueprintActivityModel1 {
    public convenience init(data: BlueprintActivityData) {
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

extension BlueprintManufacturingModel1 {
    public convenience init(data: BlueprintManufacturingData) {
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

//final class TimeAmount: Fields {
//  @Field(key: "time")
//  var time: Int64
//}G

