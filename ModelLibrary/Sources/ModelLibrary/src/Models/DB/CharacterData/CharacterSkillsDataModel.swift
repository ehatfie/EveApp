//
//  CharacterSkillsModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/18/24.
//


import Foundation
import FluentSQLiteDriver
import TestPackage3

final public class CharacterSkillsDataModel: Model {
    static public let schema = Schemas.characterSkillsDataModel.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Parent(key: "characterId")
    var characterDataModel: CharacterDataModel
    
    @Field(key: "skills") public var skills: [CharacterSkillModel]
    //@Field(key: "characterId") var characterId: String
    @Field(key: "totalSp") public var totalSp: Int64
    @Field(key: "unallocatedSp") public var unallocatedSp: Int?
    
    public init() { }
    
    public init(
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
    
    public convenience init(characterId: String, data: GetCharactersCharacterIdSkillsOk) {
        self.init(
            id: UUID(),
            skills: data.skills.map { CharacterSkillModel(characterId: characterId, data: $0) },
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
        
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterSkillsDataModel.schema)
                .delete()
        }
        
    }
}
