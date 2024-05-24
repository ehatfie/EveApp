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

final class CharacterDataModel: Model {
    static let schema = Schemas.characterDataModel.rawValue
    
    @ID(key: .id) var id: UUID?
    @Field(key: "characterId") var characterId: String
    
    @OptionalChild(for: \.$characterDataModel)
    var publicData: CharacterPublicDataModel?
    
    
    @Children(for: \.$characterDataModel)
    var assetsData: [CharacterAssetsDataModel]
    
    init() { }
    
    init(characterID: String) {
        self.characterId = characterID
    }
    
    struct ModelMigration: AsyncMigration {
        
        func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(CharacterDataModel.schema)
                .id()
                .field("characterId", .string)
                .unique(on: "characterId")
                .create()
        }
        
        func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterDataModel.schema)
                .delete()
        }
    }
}

final class CharacterPublicDataModel: Model {
    static let schema = Schemas.characterPublicDataModel.rawValue
    @ID(key: .id) var id: UUID?
    
    @Parent(key: "publicData_id")
    var characterDataModel: CharacterDataModel
    
    @Field(key: "allianceId") var allianceId: Int32?
    @Field(key: "birthday") var birthday: String
    @Field(key: "bloodlineId") var bloodlineId: Int32
    @Field(key: "corporationId") var corporationId: Int32
    @Field(key: "description") var description: String?
    @Field(key: "factionId") var factionId: Int32?
    @Field(key: "gender") var gender: String
    @Field(key: "name") var name: String
    @Field(key: "raceId") var raceId: Int32
    @Field(key: "securityStatus") var securityStatus: Float?
    @Field(key: "title") var title: String?
    
    init() { }
    
    init(
        id: UUID? = nil,
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
    
    convenience init(response: CharacterPublicDataResponse) {
        self.init(
            id: UUID(),
            allianceId: response.alliance_id,
            birthday: response.birthday,
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
        
    struct ModelMigration: AsyncMigration {
        func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(CharacterPublicDataModel.schema)
                .id()
                .field(
                    "publicData_id", 
                    .uuid,
                    .required,
                    .references(Schemas.characterDataModel.rawValue, "id")
                )
                .field("allianceId", .int32)
                .field("birthday", .string, .required)
                .field("bloodlineId", .int32)
                .field("corporationId", .int32)
                .field("description", .string)
                .field("factionId", .int32)
                .field("gender", .string, .required)
                .field("name", .string, .required)
                .field("raceId", .int32)
                .field("securityStatus", .float)
                .field("title", .string)
                .create()
        }
            
        func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterPublicDataModel.schema)
                .delete()
        }
    }
    
}
