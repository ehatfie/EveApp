//
//  CharacterSkillsModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/18/24.
//


import Foundation
import FluentSQLiteDriver


final class CharacterSkillsDataModel: Model {
    static let schema = Schemas.characterSkillsDataModel.rawValue
    
    @ID(key: .id) var id: UUID?
    
    @Parent(key: "characterId")
    var characterDataModel: CharacterDataModel
    
    @Field(key: "skills") var skills: [CharacterSkillModel]
    //@Field(key: "characterId") var characterId: String
    @Field(key: "totalSp") var totalSp: Int64
    @Field(key: "unallocatedSp") var unallocatedSp: Int?
    
    init() { }
    
    init(
        id: UUID? = UUID(),
        skills: [CharacterSkillModel],
        characterId: String,
        totalSp: Int64,
        unallocatedSp: Int?
    ) {
        self.id = id
        self.skills = skills
        //self.characterId = characterId
        self.totalSp = totalSp
        self.unallocatedSp = unallocatedSp
       // self.characterId = characterId
    }
    
    convenience init(characterId: String, data: GetCharactersCharacterIdSkillsOk) {
        self.init(
            id: UUID(),
            skills: data.skills.map { CharacterSkillModel(characterId: characterId, data: $0) },
            characterId: characterId,
            totalSp: data.totalSp,
            unallocatedSp: data.unallocatedSp
        )
    }
    
    struct ModelMigration: AsyncMigration {
        func prepare(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterSkillsDataModel.schema)
                .id()
                .field(
                    "characterId",
                    .uuid,
                    .required,
                    .references(Schemas.characterDataModel.rawValue, "id")
                )
                .field("skills", .array(of: .custom(CharacterSkillModel.self)))
                //.field("characterId", .string)
                .field("totalSp", .int64, .required)
                .field("unallocatedSp", .int)
                .create()
        }
        
        func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterSkillsDataModel.schema)
                .delete()
        }
        
    }
}
