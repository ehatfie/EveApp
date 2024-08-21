//
//  CharacterIndustryDataModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/7/24.
//

import Foundation
import FluentSQLiteDriver

final public class CharacterIndustryDataModel: Model {
    static public let schema = Schemas.characterIndustryDataModel.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    public init() { }
    
    public init(id: UUID? = nil) {
        self.id = id
    }
    
    public convenience init(
        characterId: String,
        data: GetCharactersIndustryJobsResponse
    ){
        self.init(id: UUID())
    }
}

extension CharacterIndustryDataModel {
    public struct ModelMigration: AsyncMigration {
        public func prepare(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterIndustryDataModel.schema)
                .id()
                .create()
        }
        
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterIndustryDataModel.schema)
                .delete()
        }
    }
    

}
