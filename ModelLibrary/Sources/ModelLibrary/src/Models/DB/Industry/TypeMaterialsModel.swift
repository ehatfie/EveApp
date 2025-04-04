//
//  TypeMaterialsModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/14/23.
//

import Foundation
import FluentSQLiteDriver

public struct TypeMaterialsData: Codable {
    public let materials: [MaterialData]
  
    public init(materials: [MaterialData]) {
    self.materials = materials
  }
}

public struct MaterialData: Codable {
    public let materialTypeID: Int64
    public let quantity: Int64
  
    public init(materialTypeID: Int64, quantity: Int64) {
    self.materialTypeID = materialTypeID
    self.quantity = quantity
  }
}


final public class MaterialDataModel1: Model, @unchecked Sendable {
  static public let schema = Schemas.materialDataModel.rawValue
  
  @ID(key: .id) public var id: UUID?
  
  @Parent(key: "type_materials_model") public var typeMaterialsModel: TypeMaterialsModel
  
  @Field(key: "material_type_id") public var materialTypeID: Int64
  @Field(key: "quantity") public var quantity: Int64
  
    public init() { }
  
    public init(data: MaterialData) {
    self.id = UUID()
    
    self.materialTypeID = data.materialTypeID
    self.quantity = data.quantity
  }
  
    public struct CreateMaterialDataModelMigration: Migration {
        public func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
      database.schema(MaterialDataModel1.schema)
        .id()
        .field("type_materials_model", .uuid, .required, .references("typeMaterialsModel", "id"))
        .field("materialType_id", .int64, .required)
        .field("quantity", .int64, .required)
        .create()
    }
    
        public func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
      database.schema(MaterialDataModel1.schema)
        .delete()
    }
  }
}

final public class MaterialDataModel: Fields, @unchecked Sendable {
  @Field(key: "materialType_id") public var materialTypeID: Int64
  @Field(key: "quantity") public var quantity: Int64
  
    public init() { }
  
    public init(data: MaterialData) {
    self.materialTypeID = data.materialTypeID
    self.quantity = data.quantity
  }
}

final public class TypeMaterialsModel: Model, @unchecked Sendable {
  static public let schema = Schemas.typeMaterialsModel.rawValue
  
  @ID(key: .id) public var id: UUID?
  
  @Field(key: "type_id") public var typeID: Int64
  
  @Field(key: "material_data") public var materialData: [MaterialDataModel]
  
    public init() { }
  
    public init(typeID: Int64, materialData: [MaterialData]) {
    self.id = UUID()
    self.typeID = typeID
    self.materialData = materialData.map{ MaterialDataModel(data: $0) }
  }
  
    public struct ModelMigration: Migration {
        public init() { }
        public func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
      database.schema(TypeMaterialsModel.schema)
        .id()
        .field("type_id", .int64, .required)
        .field("material_data", .array(of: .json))
//        .field("materialData", .array(of: .custom(MaterialDataModel.self)))
        .create()
    }
    
        public func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
      database.schema(TypeMaterialsModel.schema)
        .delete()
    }
  }
}

// can be for the names
final public class Pet: Fields, @unchecked Sendable {
  @Field(key: "materialTypeID") public var materialTypeID: Int64
  @Field(key: "quantity") public var quantity: Int64
    
    public init() { }
}
