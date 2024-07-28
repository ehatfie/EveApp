//
//  CharacterIndustryDataModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/7/24.
//

import Foundation
import FluentSQLiteDriver

final class CharacterIndustryDataModel: Model {
    static let schema = Schemas.characterIndustryDataModel.rawValue
    
    @ID(key: .id) var id: UUID?
    
    init() { }
    
    init(id: UUID? = nil) {
        self.id = id
    }
    
    convenience init(
        characterId: String,
        data: GetCharactersIndustryJobsResponse
    ){
        self.init(id: UUID())
    }
}

extension CharacterIndustryDataModel {
    struct ModelMigration: AsyncMigration {
        func prepare(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterIndustryDataModel.schema)
                .id()
                .create()
        }
        
        func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterIndustryDataModel.schema)
                .delete()
        }
    }
    

}
