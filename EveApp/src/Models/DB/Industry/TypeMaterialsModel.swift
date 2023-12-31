//
//  TypeMaterialsModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/14/23.
//

import Foundation
import FluentSQLiteDriver

struct TypeMaterialsData: Codable {
  let materials: [MaterialData]
  
  init(materials: [MaterialData]) {
    self.materials = materials
  }
}

struct MaterialData: Codable {
  let materialTypeID: Int64
  let quantity: Int64
  
  init(materialTypeID: Int64, quantity: Int64) {
    self.materialTypeID = materialTypeID
    self.quantity = quantity
  }
}


final class MaterialDataModel1: Model {
  static let schema = Schemas.materialDataModel.rawValue
  
  @ID(key: .id) var id: UUID?
  
  @Parent(key: "typeMaterialsModel") var typeMaterialsModel: TypeMaterialsModel
  
  @Field(key: "materialTypeID") var materialTypeID: Int64
  @Field(key: "quantity") var quantity: Int64
  
  init() { }
  
  init(data: MaterialData) {
    self.id = UUID()
    
    self.materialTypeID = data.materialTypeID
    self.quantity = data.quantity
  }
  
  struct CreateMaterialDataModelMigration: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
      database.schema(MaterialDataModel1.schema)
        .id()
        .field("typeMaterialsModel", .uuid, .required, .references("typeMaterialsModel", "id"))
        .field("materialTypeID", .int64, .required)
        .field("quantity", .int64, .required)
        .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
      database.schema(MaterialDataModel1.schema)
        .delete()
    }
  }
}

final class MaterialDataModel: Fields {
  @Field(key: "materialTypeID") var materialTypeID: Int64
  @Field(key: "quantity") var quantity: Int64
  
  init() { }
  
  init(data: MaterialData) {
    self.materialTypeID = data.materialTypeID
    self.quantity = data.quantity
  }
}

final class TypeMaterialsModel: Model {
  static let schema = Schemas.typeMaterialsModel.rawValue
  
  @ID(key: .id) var id: UUID?
  
  @Field(key: "typeID") var typeID: Int64
  
  @Field(key: "materialData") var materialData: [MaterialDataModel]
  
  init() { }
  
  init(typeID: Int64, materialData: [MaterialData]) {
    self.id = UUID()
    self.typeID = typeID
    self.materialData = materialData.map{ MaterialDataModel(data: $0) }
  }
  
  struct ModelMigration: Migration {
    func prepare(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
      database.schema(TypeMaterialsModel.schema)
        .id()
        .field("typeID", .int64, .required)
        .field("materialData", .array(of: .custom(MaterialDataModel.self)))
        .create()
    }
    
    func revert(on database: FluentKit.Database) -> NIOCore.EventLoopFuture<Void> {
      database.schema(TypeMaterialsModel.schema)
        .delete()
    }
  }
}

// can be for the names
final class Pet: Fields {
  @Field(key: "materialTypeID") var materialTypeID: Int64
  @Field(key: "quantity") var quantity: Int64
}
