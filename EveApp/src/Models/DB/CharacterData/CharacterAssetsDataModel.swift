//
//  CharacterAssetsModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/18/24.
//

import Foundation
import FluentSQLiteDriver

final class CharacterAssetsDataModel: Model {
    static let schema = Schemas.characterAssetsDataModel.rawValue
    
    @ID(key: .id) var id: UUID?
    
    @Parent(key: "characterId")
    var characterDataModel: CharacterDataModel
    
    @Field(key: "isBlueprintCopy") var isBlueprintCopy: Bool?
    @Field(key: "isSingleton") var isSingleton: Bool
    @Field(key: "itemId") var itemId: Int64
    @Field(key: "locationFlag") var locationFlag: String
    @Field(key: "locationId") var locationId: Int64
    @Field(key: "locationType") var locationType: String
    @Field(key: "quantity") var quantity: Int
    @Field(key: "typeId") var typeId: Int64
    
    init() { }
    
    init(
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
    
    convenience init(data: GetCharactersCharacterIdAssets200Ok) {
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
    
    struct ModelMigration: AsyncMigration {
        func prepare(on database: FluentKit.Database) async throws {
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
            
        func revert(on database: any FluentKit.Database) async throws {
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


