//
//  CharacterAssetsModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/18/24.
//

import Foundation
import FluentSQLiteDriver
import TestPackage3

final public class CharacterAssetsDataModel: Model {
    static public let schema = Schemas.characterAssetsDataModel.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Parent(key: "characterId")
    public var characterDataModel: CharacterDataModel
    
    @Field(key: "isBlueprintCopy") public var isBlueprintCopy: Bool?
    @Field(key: "isSingleton") public var isSingleton: Bool
    @Field(key: "itemId") public var itemId: Int64
    @Field(key: "locationFlag") public var locationFlag: String
    @Field(key: "locationId") public var locationId: Int64
    @Field(key: "locationType") public var locationType: String
    @Field(key: "quantity") public var quantity: Int
    @Field(key: "typeId") public var typeId: Int64
    
    public init() { }
    
    public init(
        id: UUID? = nil,
        isBlueprintCopy: Bool? = nil,
        isSingleton: Bool,
        itemId: Int64,
        locationFlag: String,
        locationId: Int64,
        locationType: String,
        quantity: Int,
        typeId: Int
    ) {
        self.id = id
        self.isBlueprintCopy = isBlueprintCopy
        self.isSingleton = isSingleton
        self.itemId = itemId
        self.locationFlag = locationFlag
        self.locationId = locationId
        self.locationType = locationType
        self.quantity = quantity
        self.typeId = Int64(typeId)
    }
    
    public convenience init(data: GetCharactersCharacterIdAssets200Ok) {
        self.init(
            id: UUID(),
            isBlueprintCopy: data.isBlueprintCopy,
            isSingleton: data.isSingleton,
            itemId: data.itemId,
            locationFlag: data.locationFlag.rawValue,
            locationId: data.locationId,
            locationType: data.locationType.rawValue,
            quantity: data.quantity,
            typeId: data.typeId
        )
    }
    
    public struct ModelMigration: AsyncMigration {
        public init() { }
        public func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(CharacterAssetsDataModel.schema)
                .id()
                .field(
                    "characterId",
                    .uuid,
                    .required,
                    .references(Schemas.characterDataModel.rawValue, "id")
                )
                .field("isBlueprintCopy", .bool)
                .field("isSingleton", .bool, .required)
                .field("itemId", .int64, .required)
                .field("locationFlag", .string, .required)
                .field("locationId", .int64, .required)
                .field("locationType", .string, .required)
                .field("quantity", .int, .required)
                .field("typeId", .int64, .required)
                .create()
        }
            
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterAssetsDataModel.schema)
                .delete()
        }
    }
    
//    static func edit(id:String, password:String? ) throws -> CharacterAssetsDataModel {
//        try CharacterAssetsDataModel.find(
//        guard var user:ClinicUser = try ClinicUser.find(id) else {
//            throw Abort.notFound
//        }
//        // Is it the best way of doing this? Because with "guard" I should "return" or "throw", right?
//        if password != nil {
//            user.password = try BCrypt.hash(password: password!)
//        }
//        
//        // TODO: update user's roles relationships
//
//        try user.save()
//        
//        return user
//    }
}


