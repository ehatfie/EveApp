//
//  TypeDogmaModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/9/23.
//

import Foundation
import FluentSQLiteDriver

struct TypeDogmaData: Codable {
  let dogmaAttributes: [DogmaAttributeInfo]
  let dogmaEffects: [DogmaEffectInfo]
}

struct DogmaAttributeInfo: Codable {
  let attributeID: Int64
  let value: Double
}

struct DogmaEffectInfo: Codable {
  let effectID: Int64
  let isDefault: Bool
}

final class TypeDogmaAttribute: Fields {
  @Field(key: "attributeId") var attributeID: Int64
  @Field(key: "value") var value: Double
  
  init() {
    self.attributeID = 0
    self.value = 0
  }
  
  init(data: DogmaAttributeInfo) {
    self.attributeID = data.attributeID
    self.value = data.value
  }
}

final class TypeDogmaEffect: Fields {
  @Field(key: "effectID") var effectID: Int64
  @Field(key: "isDefault") var isDefault: Bool
  
  init() {
    self.effectID = 0
    self.isDefault = false
  }
  
  init(data: DogmaEffectInfo) {
    self.effectID = data.effectID
    self.isDefault = data.isDefault
  }
}

final class TypeDogmaInfoModel: Model {
  static let schema = Schemas.typeDogmaInfo.rawValue
  
  @ID(key: .id) var id: UUID?
  
  @Field(key: "typeId") var typeId: Int64
  
//  @Children(for: \.$typeDogmaInfoModel) var attributes: [TypeDogmaAttributeInfoModel]
  @Field(key: "attributes") var attributes: [TypeDogmaAttribute]
  @Field(key: "effects") var effects: [TypeDogmaEffect]
 // @Children(for: \.$typeDogmaInfoModel) var effects: [TypeDogmaEffectInfoModel]
  
  init() { }
  
  init(typeId: Int64, data: TypeDogmaData) {
    self.id = UUID()
    self.typeId = typeId
    self.attributes = []
    
    var set = Set<Int64>()

    let dogmaAttributeValues = data.dogmaAttributes.map { TypeDogmaAttribute(data: $0)}
    
    dogmaAttributeValues.forEach { value in
      set.insert(value.attributeID)
    }
    
    if set.count != dogmaAttributeValues.count {
      print("have \(data.dogmaAttributes.count) attributes but \(set.count) unique values")
    }
    
    self.attributes = dogmaAttributeValues
    //self.effects = []
    self.effects = data.dogmaEffects.map { TypeDogmaEffect(data: $0)}
    //self.attributes = attributes
    //self.effects = effects
  }
  

  
      struct CreateTypeDogmaInfoModel: Migration {
          func prepare(on database: Database) -> EventLoopFuture<Void> {
              database.schema(TypeDogmaInfoModel.schema)
                  .id()
                  .field("typeId", .int64, .required)
                  .field("attributes", .array(of: .custom(TypeDogmaAttribute.self)))
                  .field("effects", .array(of: .custom(TypeDogmaEffect.self)))
                  .create()
          }
  
          func revert(on database: Database) -> EventLoopFuture<Void> {
              database.schema(TypeDogmaInfoModel.schema)
                  .delete()
          }
      }
}

//struct CreateTypeDogmaInfoModel: Migration {
//  func prepare(on database: Database) -> EventLoopFuture<Void> {
//    database.schema(TypeDogmaInfoModel.schema)
//      .id()
//      .field("typeId", .int64, .required)
//      .create()
//  }
//  
//  func revert(on database: Database) -> EventLoopFuture<Void> {
//    database.schema(TypeDogmaInfoModel.schema)
//      .delete()
//  }
//}

final class TypeDogmaAttributeInfoModel: Model {
  static let schema = Schemas.typeDogmaAttributeInfo.rawValue
  
  @ID(key: .id) var id: UUID?
  
  @Parent(key: "typeDogmaInfoModel")
  var typeDogmaInfoModel: TypeDogmaInfoModel
  @Field(key: "typeId") var typeID: Int64
  @Field(key: "attributeId") var attributeID: Int64
  @Field(key: "value") var value: Double
  
  init() { }
  
  init(typeID: Int64, attributeID: Int64, value: Double) {
    self.id = UUID()
    self.typeID = typeID
    self.attributeID = attributeID
    self.value = value
    //self.typeDogmaInfoModel = info
  }
}

struct CreateTypeDogmaAttributeInfoModel: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema(TypeDogmaAttributeInfoModel.schema)
      .id()
      .field("typeDogmaInfoModel", .uuid, .required, .references(Schemas.typeDogmaInfo.rawValue, "id"))
      .field("typeId", .int64, .required)
      .field("attributeId", .int64, .required)
      .field("value", .double, .required)
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(TypeDogmaAttributeInfoModel.schema)
      .delete()
  }
}

final class TypeDogmaEffectInfoModel: Model {
  static let schema = Schemas.typeDogmaEffectInfo.rawValue
  
  @ID(key: .id) var id: UUID?
  
  @Parent(key: "typeDogmaInfoModel")
  var typeDogmaInfoModel: TypeDogmaInfoModel
  
  @Field(key: "effectID") var effectID: Int64
  @Field(key: "isDefault") var isDefault: Bool
  
  init() { }
  
  init(effectID: Int64, isDefault: Bool) {
    self.id = UUID()
    self.effectID = effectID
    self.isDefault = isDefault
  }
}

struct CreateTypeDogmaEffectInfoModel: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema(TypeDogmaEffectInfoModel.schema)
      .id()
      .field("typeDogmaInfoModel", .uuid, .required, .references(Schemas.typeDogmaInfo.rawValue, "id"))
      .field("effectID", .int64, .required)
      .field("isDefault", .bool, .required)
      .create()
  }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(TypeDogmaAttributeInfoModel.schema)
      .delete()
  }
}

