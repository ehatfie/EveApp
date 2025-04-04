//
//  CharacterDataModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/15/24.
//

import Foundation
import FluentSQLiteDriver
/*
 
 struct CharacterPublicDataResponse: Decodable {
     let alliance_id: Int32?
     let birthday: String // date-time
     let bloodline_id: Int32
     let corporation_id: Int32
     let description: String?
     let faction_id: Int32?
     let gender: String
     let name: String
     let race_id: Int32
     let security_status: Float?
     let title: String?
 }

 */
@preconcurrency
final public class CharacterDataModel: Model, @unchecked Sendable {
    static public let schema = Schemas.characterDataModel.rawValue
    
    @ID(key: .id) public var id: UUID?
    @Field(key: "character_id") public var characterId: String
    
    @OptionalChild(for: \.$characterDataModel)
    public var publicData: CharacterPublicDataModel?
    
    @OptionalChild(for: \.$characterDataModel)
    public var skillsData: CharacterSkillsDataModel?
    
    @OptionalChild(for: \.$characterDataModel)
    public var walletData: CharacterWalletModel?
    
    @Children(for: \.$characterDataModel)
    public var assetsData: [CharacterAssetsDataModel]
    
    @Children(for: \.$characterDataModel)
    public var industryJobsData: [CharacterIndustryJobModel]
    
    @Siblings(through: CharacterCorporationModel.self, from: \.$character, to: \.$corporation)
    public var corp: [CorporationInfoModel]
    
    public init() { }
    
    public init(characterID: String) {
        self.characterId = characterID
    }
    
    public struct ModelMigration: AsyncMigration {
        public init() { }
        public func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(CharacterDataModel.schema)
                .id()
                .field("character_id", .string)
                .unique(on: "character_id")
                .create()
        }
        
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterDataModel.schema)
                .delete()
        }
    }
}

final public class CharacterPublicDataModel: Model, @unchecked Sendable {
    static public let schema = Schemas.characterPublicDataModel.rawValue
    @ID(key: .id) public var id: UUID?
    
    @OptionalParent(key: "publicData_id")
    public var characterDataModel: CharacterDataModel?
    
    @Field(key: "character_id") public var characterId: Int64
    @Field(key: "alliance_id") public var allianceId: Int32?
    @Field(key: "birthday") public var birthday: String
    @Field(key: "bloodline_id") public var bloodlineId: Int32
    @Field(key: "corporation_id") public var corporationId: Int32
    @Field(key: "description") public var description: String?
    @Field(key: "faction_id") public var factionId: Int32?
    @Field(key: "gender") public var gender: String
    @Field(key: "name") public var name: String
    @Field(key: "race_id") public var raceId: Int32
    @Field(key: "security_status") public var securityStatus: Float?
    @Field(key: "title") public var title: String?
    
    public init() { }
    
    public init(
        id: UUID? = nil,
        characterId: Int64,
        allianceId: Int32? = nil,
        birthday: String,
        bloodlineId: Int32,
        corporationId: Int32,
        description: String? = nil,
        factionId: Int32? = nil,
        gender: String,
        name: String,
        raceId: Int32,
        securityStatus: Float? = nil,
        title: String? = nil
    ) {
        self.id = id
        self.characterId = characterId
        self.allianceId = allianceId
        self.birthday = birthday
        self.bloodlineId = bloodlineId
        self.corporationId = corporationId
        self.description = description
        self.factionId = factionId
        self.gender = gender
        self.name = name
        self.raceId = raceId
        self.securityStatus = securityStatus
        self.title = title
    }
    
    public convenience init(response: CharacterPublicDataResponse, characterId: Int64) {
        self.init(
            id: UUID(),
            characterId: characterId,
            allianceId: response.alliance_id,
            birthday: response.birthday ?? "NO_BIRTHDAY",
            bloodlineId: response.bloodline_id,
            corporationId: response.corporation_id,
            description: response.description,
            factionId: response.faction_id,
            gender: response.gender,
            name: response.name,
            raceId: response.race_id,
            securityStatus: response.security_status,
            title: response.title
        )
    }
        
    public struct ModelMigration: AsyncMigration {
        public init() { }
        public func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(CharacterPublicDataModel.schema)
                .id()
                .field(
                    "publicData_id", 
                    .uuid,
                    .references(Schemas.characterDataModel.rawValue, "id")
                )
                .field("character_id", .int64, .required)
                .field("alliance_id", .int32)
                .field("birthday", .string, .required)
                .field("bloodline_id", .int32)
                .field("corporation_id", .int32)
                .field("description", .string)
                .field("faction_id", .int32)
                .field("gender", .string, .required)
                .field("name", .string, .required)
                .field("race_id", .int32)
                .field("security_status", .float)
                .field("title", .string)
                .unique(on: "character_id")
                .create()
        }
            
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterPublicDataModel.schema)
                .delete()
        }
    }
    
}
