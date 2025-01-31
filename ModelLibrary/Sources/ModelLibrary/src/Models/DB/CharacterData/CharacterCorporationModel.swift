//
//  CharacterCorporationModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/6/24.
//

import Foundation
import Fluent

final public class CharacterCorporationModel: Model, @unchecked Sendable {
    static public let schema = Schemas.characterCorporationModel.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Parent(key: "characterId") public var character: CharacterDataModel
    @Parent(key: "corporationId") public var corporation: CorporationInfoModel
    
    public init() { }
    
    public init(
        character: CharacterDataModel,
        corporation: CorporationInfoModel
    ) throws {
        self.id = UUID()
        self.$character.id = try character.requireID()
        self.$corporation.id = try corporation.requireID()
    }
    
    public struct ModelMigration: AsyncMigration {
        public init() { }
        public func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(CharacterCorporationModel.schema)
                .id()
                .field(
                    "characterId",
                    .uuid,
                    .required,
                    .references(Schemas.characterDataModel.rawValue, "id")
                )
                .field(
                    "corporationId",
                    .uuid,
                    .required,
                    .references(Schemas.corporationInfoModel.rawValue, "id")
                )
                .unique(on: "characterId", "corporationId")
                .create()
        }
        
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterCorporationModel.schema)
                .delete()
        }
    }
}
