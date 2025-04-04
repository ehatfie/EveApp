//
//  CharacterAssetsModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/18/24.
//

import Foundation
import FluentSQLiteDriver

final public class CharacterAssetsDataModel: Model, @unchecked Sendable {
    static public let schema = Schemas.characterAssetsDataModel.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Parent(key: "character_id")
    var characterDataModel: CharacterDataModel
    
    @Field(key: "is_blueprint_copy") public var isBlueprintCopy: Bool?
    @Field(key: "is_singleton") public var isSingleton: Bool
    @Field(key: "item_id") public var itemId: Int64
    @Field(key: "location_flag") public var locationFlag: String
    @Field(key: "location_id") public var locationId: Int64
    @Field(key: "location_type") public var locationType: String
    @Field(key: "quantity") public var quantity: Int64
    @Field(key: "type_id") public var typeId: Int64
    
     public init() { }
    
     init(
        id: UUID? = nil,
        isBlueprintCopy: Bool? = nil,
        isSingleton: Bool,
        itemId: Int64,
        locationFlag: String,
        locationId: Int64,
        locationType: String,
        quantity: Int64,
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
            quantity: Int64(data.quantity),
            typeId: data.typeId
        )
    }
    
    public struct ModelMigration: AsyncMigration {
        public init() { }
        public func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(CharacterAssetsDataModel.schema)
                .id()
                .field(
                    "character_id",
                    .uuid,
                    .required,
                    .references(Schemas.characterDataModel.rawValue, "id")
                )
                .field("is_blueprint_copy", .bool)
                .field("is_singleton", .bool, .required)
                .field("item_id", .int64, .required)
                .field("location_flag", .string, .required)
                .field("location_id", .int64, .required)
                .field("location_type", .string, .required)
                .field("quantity", .int64, .required)
                .field("type_id", .int64, .required)
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


