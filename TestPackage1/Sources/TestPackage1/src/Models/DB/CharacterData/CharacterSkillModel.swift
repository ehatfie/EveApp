//
//  CharacterSkillModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/18/24.
//

import Foundation
import FluentSQLiteDriver
import TestPackage3

final public class CharacterSkillModel: Fields, @unchecked Sendable {
    //static let schema = Schemas.characterSkillModel.rawValue
    
    //@ID(key: .id) var id: UUID?
    
    @Field(key: "activeSkillLevel") public var activeSkillLevel: Int
    @Field(key: "skillId") public var skillId: Int
    @Field(key: "skillPointsInSkill") public var skillpointsInSkill: Int64
    @Field(key: "trainedSkillLevel") public var trainedSkillLevel: Int
    
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
