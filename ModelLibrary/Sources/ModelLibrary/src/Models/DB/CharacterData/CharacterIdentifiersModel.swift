//
//  CharacterIdentifiersModel.swift
//  ModelLibrary
//
//  Created by Erik Hatfield on 9/11/24.
//

import Foundation
import FluentSQLiteDriver

final public class CharacterIdentifiersModel: Model, @unchecked Sendable {
    static public let schema = Schemas.characterIdentifiersModel.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Field(key: "character_id") public var characterID: Int64
    @Field(key: "name") public var name: String
    @Field(key: "corporation_id") public var corporationID: Int64
    @Field(key: "alliance_id") public var allianceID: Int64?
    
    public init() { }
    
    public init(
        id: UUID? = UUID(),
        characterID: Int64,
        name: String,
        corporationID: Int64,
        allianceID: Int64? = nil
    ) {
        self.id = id
        self.characterID = characterID
        self.name = name
        self.corporationID = corporationID
        self.allianceID = allianceID
    }
    
    public convenience init(
        characterId: Int64,
        data: CharacterPublicDataResponse) {
        self.init(
            characterID: characterId,
            name: data.name,
            corporationID: Int64(data.corporation_id),
            allianceID: Int64(data.alliance_id ?? -1)
        )
    }
    
    public struct ModelMigration: AsyncMigration {
        public init() { }
        
        public func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(CharacterIdentifiersModel.schema)
                .id()
                .field("character_id", .int64, .required)
                .field("name", .string, .required)
                .field("corporation_id", .int64, .required)
                .field("alliance_id", .int64)
                .unique(on: "character_id")
                .create()
        }
        
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterIdentifiersModel.schema)
                .delete()
        }
    }
}
