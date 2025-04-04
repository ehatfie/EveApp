//
//  TypeDogmaModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/9/23.
//

import Foundation
import FluentSQLiteDriver

public struct TypeDogmaData: Codable {
    public let dogmaAttributes: [DogmaAttributeInfo]
    public let dogmaEffects: [DogmaEffectInfo]
    
    public init(dogmaAttributes: [DogmaAttributeInfo], dogmaEffects: [DogmaEffectInfo]) {
        self.dogmaAttributes = dogmaAttributes
        self.dogmaEffects = dogmaEffects
    }
}

public struct DogmaAttributeInfo: Codable {
    public let attributeID: Int64
    public let value: Double
    
    public init(attributeID: Int64, value: Double) {
        self.attributeID = attributeID
        self.value = value
    }
}

public struct DogmaEffectInfo: Codable {
    public let effectID: Int64
    public let isDefault: Bool
    
    public init(effectID: Int64, isDefault: Bool) {
        self.effectID = effectID
        self.isDefault = isDefault
    }
}

final public class TypeDogmaAttribute: Fields, @unchecked Sendable {
    @Field(key: "attribute_id") public var attributeID: Int64
    @Field(key: "value") public var value: Double
    
    public init() {
        self.attributeID = 0
        self.value = 0
    }
    
    public init(data: DogmaAttributeInfo) {
        self.attributeID = data.attributeID
        self.value = data.value
    }
}

final public class TypeDogmaEffect: Fields, @unchecked Sendable {
    @Field(key: "effect_id") public var effectID: Int64
    @Field(key: "is_default") public var isDefault: Bool
    
    public init() {
        self.effectID = 0
        self.isDefault = false
    }
    
    public init(data: DogmaEffectInfo) {
        self.effectID = data.effectID
        self.isDefault = data.isDefault
    }
}

final public class TypeDogmaInfoModel: Model, @unchecked Sendable {
    static public let schema = Schemas.typeDogmaInfo.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Field(key: "type_id") public var typeId: Int64
    
    //  @Children(for: \.$typeDogmaInfoModel) var attributes: [TypeDogmaAttributeInfoModel]
    @Field(key: "attributes") public var attributes: [TypeDogmaAttribute]
    @Field(key: "effects") public var effects: [TypeDogmaEffect]
    // @Children(for: \.$typeDogmaInfoModel) var effects: [TypeDogmaEffectInfoModel]
    
    public init() { }
    
    public init(typeId: Int64, data: TypeDogmaData) {
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
    
    
    
    public struct CreateTypeDogmaInfoModel: Migration {
        public init() { }
        public func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(TypeDogmaInfoModel.schema)
                .id()
                .field("type_id", .int64, .required)
//                .field("attributes", .array(of: .custom(TypeDogmaAttribute.self)))
//                .field("effects", .array(of: .custom(TypeDogmaEffect.self)))
                .field("attributes", .array(of: .json))
                .field("effects", .array(of: .json))
                .create()
        }
        
        public func revert(on database: Database) -> EventLoopFuture<Void> {
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

final public class TypeDogmaAttributeInfoModel: Model, @unchecked Sendable {
    static public let schema = Schemas.typeDogmaAttributeInfo.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Parent(key: "type_dogma_info_model")
    public var typeDogmaInfoModel: TypeDogmaInfoModel
    @Field(key: "type_id") public var typeID: Int64
    @Field(key: "attribute_id") public var attributeID: Int64
    @Field(key: "value") public var value: Double
    
    public init() { }
    
    public init(typeID: Int64, attributeID: Int64, value: Double) {
        self.id = UUID()
        self.typeID = typeID
        self.attributeID = attributeID
        self.value = value
        //self.typeDogmaInfoModel = info
    }
}

public struct CreateTypeDogmaAttributeInfoModel: Migration {
    public init() { }
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TypeDogmaAttributeInfoModel.schema)
            .id()
            .field("type_dogma_info_model", .uuid, .required, .references(Schemas.typeDogmaInfo.rawValue, "id"))
            .field("type_id", .int64, .required)
            .field("attribute_id", .int64, .required)
            .field("value", .double, .required)
            .create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TypeDogmaAttributeInfoModel.schema)
            .delete()
    }
}

final public class TypeDogmaEffectInfoModel: Model, @unchecked Sendable {
    static public let schema = Schemas.typeDogmaEffectInfo.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Parent(key: "type_dogma_info_model")
    public var typeDogmaInfoModel: TypeDogmaInfoModel
    
    @Field(key: "effect_id") public var effectID: Int64
    @Field(key: "is_default") public var isDefault: Bool
    
    public init() { }
    
    public init(effectID: Int64, isDefault: Bool) {
        self.id = UUID()
        self.effectID = effectID
        self.isDefault = isDefault
    }
}

public struct CreateTypeDogmaEffectInfoModel: Migration {
    public init() { }
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TypeDogmaEffectInfoModel.schema)
            .id()
            .field("type_dogma_info_model", .uuid, .required, .references(Schemas.typeDogmaInfo.rawValue, "id"))
            .field("effect_id", .int64, .required)
            .field("is_default", .bool, .required)
            .create()
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(TypeDogmaAttributeInfoModel.schema)
            .delete()
    }
}

