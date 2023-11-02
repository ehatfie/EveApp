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
    @Children(for: \.$typeDogmaInfoModel) var effects: [TypeDogmaEffectInfoModel]
    
    init() { }
    
    init(typeId: Int64) {
        self.id = UUID()
        self.typeId = typeId
        //self.attributes = attributes
        //self.effects = effects
    }
    
//    struct CreateTypeDogmaInfoModel: Migration {
//        func prepare(on database: Database) -> EventLoopFuture<Void> {
//            database.schema(TypeDogmaInfoModel.schema)
//                .id()
//                .create()
//        }
//        
//        func revert(on database: Database) -> EventLoopFuture<Void> {
//            database.schema(TypeDogmaInfoModel.schema)
//                .delete()
//        }
//    }
}

struct CreateTypeDogmaInfoModel: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TypeDogmaInfoModel.schema)
            .id()
            .field("typeId", .int64, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TypeDogmaInfoModel.schema)
            .delete()
    }
}

final class TypeDogmaAttributeInfoModel: Model {
    static let schema = Schemas.typeDogmaAttributeInfo.rawValue
    
    @ID(key: .id) var id: UUID?
    
    @Parent(key: "typeDogmaInfoModel")
    var typeDogmaInfoModel: TypeDogmaInfoModel
    @Field(key: "typeId") var typeID: Int64
    @Field(key: "attributeId") var attributeID: Int
    @Field(key: "value") var value: Double
    
    init() { }
    
    init(typeID: Int64, attributeID: Int, value: Double) {
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
    
    @Parent(key: "typeDogmaInfoModel")
    var typeDogmaInfoModel: TypeDogmaInfoModel
    
    @Field(key: "effectID") var effectID: Int
    @Field(key: "isDefault") var isDefault: Bool
    
    init() { }
    
    init(effectID: Int, isDefault: Bool) {
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
            .field("effectID", .int, .required)
            .field("isDefault", .bool, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TypeDogmaAttributeInfoModel.schema)
            .delete()
    }
}

