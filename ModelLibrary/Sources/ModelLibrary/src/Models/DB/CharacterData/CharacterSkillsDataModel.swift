//
//  CharacterSkillsModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/18/24.
//


import Foundation
import FluentSQLiteDriver

final public class CharacterSkillsDataModel: Model, @unchecked Sendable {
    static public let schema = Schemas.characterSkillsDataModel.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Parent(key: "character_id")
    var characterDataModel: CharacterDataModel
    
    @Field(key: "character_id_reference")
    var characterIdReference: String
    
    
    @Children(for: \.$characterSkillsModel) public var skills: [CharacterSkillModel]
    //@Field(key: "characterId") var characterId: String
    @Field(key: "total_sp") public var totalSp: Int64
    @Field(key: "unallocated_sp") public var unallocatedSp: Int?
    
    public init() { }
    
    public init(
        id: UUID? = UUID(),
        characterId: String,
        totalSp: Int64,
        unallocatedSp: Int?
    ) {
        self.id = id
        //self.skills = skills
        //self.characterId = characterId
        self.totalSp = totalSp
        self.unallocatedSp = unallocatedSp
        self.characterIdReference = characterId
       // self.characterId = characterId
    }
    
    public convenience init(characterId: String, data: GetCharactersCharacterIdSkillsOk) {
        self.init(
            id: UUID(),
            characterId: characterId,
            totalSp: data.totalSp,
            unallocatedSp: data.unallocatedSp
        )
    }
    
    public struct ModelMigration: AsyncMigration {
        public init() { }
        public func prepare(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterSkillsDataModel.schema)
                .id()
                .field(
                    "character_id",
                    .uuid,
                    .required,
                    .references(Schemas.characterDataModel.rawValue, "id")
                )
                .field("character_id_reference", .string, .required)
                //.field("characterId", .string)
                .field("total_sp", .int64, .required)
                .field("unallocated_sp", .int)
                .create()
        }
        
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterSkillsDataModel.schema)
                .delete()
        }
        
    }
}
