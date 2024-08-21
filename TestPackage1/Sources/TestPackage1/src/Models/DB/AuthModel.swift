//
//  AuthModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/23/24.
//

import Foundation
import FluentSQLiteDriver


/**
 struct AccessTokenResponse: Codable {
     let access_token: String
     let expires_in: Int
     let token_type: String
     let refresh_token: String
 }

 */
final public class AuthModel: Model {
    static public let schema = Schemas.auth.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Field(key: "characterId") public var characterId: String
    @Field(key: "refreshToken") public var refreshToken: String
    @Field(key: "tokenType") public var tokenType: String
    @Field(key: "accessToken") public var accessToken: String
    @Field(key: "expiration") public var expiration: Int64
    
    public init() { }
    
    public init(id: UUID? = nil, characterId: String, refreshToken: String, tokenType: String, accessToken: String, expiration: Int64) {
        self.id = id
        self.characterId = characterId
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.accessToken = accessToken
        self.expiration = expiration
    }
    
    public convenience init(characterId: String, response: AccessTokenResponse) {
        self.init(
            id: UUID(),
            characterId: characterId,
            refreshToken: response.refresh_token,
            tokenType: response.token_type,
            accessToken: response.access_token,
            expiration: Int64(Date().timeIntervalSinceReferenceDate) + Int64(response.expires_in)
        )
    }
    
    public struct ModelMigration: AsyncMigration {
        public init() { }
        public func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(AuthModel.schema)
                .id()
                .field("characterId", .string, .required)
                .field("refreshToken", .string, .required)
                .field("tokenType", .string, .required)
                .field("accessToken", .string, .required)
                .field("expiration", .int64, .required)
                .create()
        }
            
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(AuthModel.schema)
                .delete()
        }
    }
}
