//
//  CharacterSkillModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/18/24.
//

import Foundation
import FluentSQLiteDriver

final public class CharacterSkillModel1: Fields, @unchecked Sendable {
    //static let schema = Schemas.characterSkillModel.rawValue
    
    //@ID(key: .id) var id: UUID?
    
    @Field(key: "active_skill_level") public var activeSkillLevel: Int
    @Field(key: "skill_id") public var skillId: Int
    @Field(key: "skill_points_in_skill") public var skillpointsInSkill: Int64
    @Field(key: "trained_skill_level") public var trainedSkillLevel: Int
    
    public init() { }
    
    public init(
        id: UUID? = UUID(),
        activeSkillLevel: Int,
        skillId: Int,
        skillPointsInSkill: Int64,
        trainedSkillLevel: Int
    ) {
       // self.id = id
        self.activeSkillLevel = activeSkillLevel
        self.skillId = skillId
        self.skillpointsInSkill = skillPointsInSkill
        self.trainedSkillLevel = trainedSkillLevel
       // self.characterId = characterId
        //GetCharactersCharacterIdIndustryJobs200Ok
        //GetCharactersIndustryJobsResponse
    }
    
    public convenience init(characterId: String, data: GetCharactersCharacterIdSkillsSkill) {
        self.init(
            id: UUID(),
            activeSkillLevel: data.activeSkillLevel,
            skillId: data.skillId,
            skillPointsInSkill: data.skillpointsInSkill,
            trainedSkillLevel: data.trainedSkillLevel
        )
    }
    
//    struct ModelMigration: AsyncMigration {
//        func prepare(on database: any FluentKit.Database) async throws {
//            try await database.schema(CharacterSkillModel.schema)
//                .id()
//                .field("activeSkillLevel", .int, .required)
//                .field("skillId", .int, .required)
//                .field("skillpointsInSkill", .int64, .required)
//                .field( "trainedSkillLevel", .int, .required)
//                .create()
//        }
//        
//        func revert(on database: any FluentKit.Database) async throws {
//            try await database.schema(CharacterSkillModel.schema)
//                .delete()
//        }
//        
//    }
}

final public class CharacterSkillModel: Model, @unchecked Sendable {
    static public let schema = Schemas.characterSkillModel.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Parent(key: "character_id_reference")
    public var characterSkillsModel: CharacterSkillsDataModel
    
    @Field(key: "active_skill_level") public var activeSkillLevel: Int
    @Field(key: "skill_id") public var skillId: Int
    @Field(key: "skill_points_in_skill") public var skillpointsInSkill: Int64
    @Field(key: "trained_skill_level") public var trainedSkillLevel: Int
    
    public init() { }
    
    public init(
        id: UUID? = UUID(),
        activeSkillLevel: Int,
        skillId: Int,
        skillPointsInSkill: Int64,
        trainedSkillLevel: Int
    ) {
       // self.id = id
        self.activeSkillLevel = activeSkillLevel
        self.skillId = skillId
        self.skillpointsInSkill = skillPointsInSkill
        self.trainedSkillLevel = trainedSkillLevel
    }
    
    public convenience init(
        id: UUID? = UUID(),
        data: GetCharactersCharacterIdSkillsSkill
    ) {
        self.init(
            id: id,
            activeSkillLevel: data.activeSkillLevel,
            skillId: data.skillId,
            skillPointsInSkill: data.skillpointsInSkill,
            trainedSkillLevel: data.trainedSkillLevel
        )
    }
    
        public struct ModelMigration: AsyncMigration {
            public init() { }
            public func prepare(on database: any FluentKit.Database) async throws {
                try await database.schema(CharacterSkillModel.schema)
                    .id()
                    .field(
                        "character_id_reference",
                        .uuid,
                        .required,
                        .references(Schemas.characterSkillsDataModel.rawValue, "id")
                    )
                    .field("active_skill_level", .int, .required)
                    .field("skill_id", .int, .required)
                    .field("skill_points_in_skill", .int64, .required)
                    .field( "trained_skill_level", .int, .required)
                    .create()
            }
    
            public func revert(on database: any FluentKit.Database) async throws {
                try await database.schema(CharacterSkillModel.schema)
                    .delete()
            }
    
        }
}
