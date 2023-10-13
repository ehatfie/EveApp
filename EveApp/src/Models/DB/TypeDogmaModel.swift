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
    let attributeID: Int
    let value: Double
}

struct DogmaEffectInfo: Codable {
    let effectID: Int
    let isDefault: Bool
}

final class TypeDogmaInfoModel: Model {
    static let schema = Schemas.typeDogmaInfo.rawValue
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "typeId") var typeId: Int64
    
    @Children(for: \.$typeDogmaInfoModel) var attributes: [TypeDogmaAttributeInfoModel]
    
    //@Children(for: \.$effectID) var effects: [TypeDogmaEffectInfoModel]
    
    init() { }
    
    init(typeId: Int64, attributes: [TypeDogmaAttributeInfoModel], effects: [TypeDogmaEffectInfoModel]) {
        self.id = UUID()
        self.attributes = attributes
        //self.effects = effects
    }
}

final class TypeDogmaAttributeInfoModel: Model {
    static let schema = Schemas.typeDogmaAttributeInfo.rawValue
    
    @ID(key: .id) var id: UUID?
    
    @Parent(key: "typeDogmaInfoModel")
    var typeDogmaInfoModel: TypeDogmaInfoModel
    
    @Field(key: "attributeId") var attributeID: Int
    @Field(key: "value") var value: Double
    
    init() { }
    
    init(attributeID: Int, value: Double) {
        self.attributeID = attributeID
        self.value = value
    }
}

struct CreateTypeDogmaAttributeInfoModel: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TypeDogmaAttributeInfoModel.schema)
            .id()
            .field("typeDogmaInfoModel", .uuid, .required, .references("typeDogmaInfoMode", "id"))
            .field("itemId", .int64, .required)
            .field("attributeId", .int, .required)
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
    
    @Field(key: "effectID") var effectID: Int
    @Field(key: "isDefault") var isDefault: Bool
    
    init() { }
    
    init(effectID: Int, isDefault: Bool) {
        self.effectID = effectID
        self.isDefault = isDefault
    }
}

struct CreateTypeDogmEffectInfoModel: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TypeDogmaEffectInfoModel.schema)
            .id()
            .field("effectID", .int, .required)
            .field("isDefault", .bool, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TypeDogmaAttributeInfoModel.schema)
            .delete()
    }
}

