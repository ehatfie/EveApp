//
//  CharacterCorporationModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/6/24.
//

import Foundation
import Fluent

final class CharacterCorporationModel: Model {
    static let schema = Schemas.characterCorporationModel.rawValue
    
    @ID(key: .id) var id: UUID?
    
    @Parent(key: "characterId") var character: CharacterDataModel
    @Parent(key: "corporationId") var corporation: CorporationInfoModel
    
    init() { }
    
    init(
        character: CharacterDataModel,
        corporation: CorporationInfoModel
    ) throws {
        self.id = UUID()
        self.$character.id = try character.requireID()
        self.$corporation.id = try corporation.requireID()
    }
    
    struct ModelMigration: AsyncMigration {
        func prepare(on database: FluentKit.Database) async throws {
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
        
        func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterCorporationModel.schema)
                .delete()
        }
    }
}
