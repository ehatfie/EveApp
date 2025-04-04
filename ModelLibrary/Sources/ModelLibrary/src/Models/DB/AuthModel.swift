//
//  AuthModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/23/24.
//

import Foundation
import FluentSQLiteDriver
import SwiftEveAuth

/**
 struct AccessTokenResponse: Codable {
     let access_token: String
     let expires_in: Int
     let token_type: String
     let refresh_token: String
 }

 */
final public class AuthModel: Model, @unchecked Sendable {
    static public let schema = Schemas.auth.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Field(key: "character_id") public var characterId: String
    @Field(key: "refresh_token") public var refreshToken: String
    @Field(key: "token_type") public var tokenType: String
    @Field(key: "access_token") public var accessToken: String
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
                .field("character_id", .string, .required)
                .field("refresh_token", .string, .required)
                .field("token_type", .string, .required)
                .field("access_token", .string, .required)
                .field("expiration", .int64, .required)
                .create()
        }
            
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(AuthModel.schema)
                .delete()
        }
    }
}
