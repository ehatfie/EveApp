//
//  Models.swift
//  SwiftEveAuth
//
//  Created by Erik Hatfield on 11/25/24.
//

public enum ESIScopes: String {
    static let root = "esi-skills."
    static let version = ".v1"
    
    case skills = "esi-skills.read_skills.v1"
    case skillQueue = "esi-skills.read_skillqueue.v1"
    case assets = "esi-assets.read_assets.v1"
    case structureInfo = "esi-universe.read_structures.v1" //esi-universe.read_structures.v1
    case characterIndustryJobs = "esi-industry.read_character_jobs.v1"
    case wallet = "esi-wallet.read_character_wallet.v1"
    case searchStructures = "esi-search.search_structures.v1"
}

public struct AuthConfig {
    public let clientInfo: ClientInfo
  
    public let authorizationCodeURL: String
    public let accessTokenURL: String
    public let state: String
  
    public let codeVerifier: String
    public let codeChallenge: String
  
    public let scopes: Set<ESIScopes>
}

public struct AuthData {
    public let characterID: String
    public let refreshToken: String
    public let tokenType: String
    public let accessToken: String
    public let expiration: Int64
    
    public init(
        characterID: String,
        refreshToken: String,
        tokenType: String,
        accessToken: String,
        expiration: Int64
    ) {
        self.characterID = characterID
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.accessToken = accessToken
        self.expiration = expiration
    }
}

public struct AccessTokenResponse: Codable {
    public let access_token: String
    public let expires_in: Int
    public let token_type: String
    public let refresh_token: String
}

public struct ClientInfo: Codable {
    public let clientID: String
    public let secretKey: String
    public let callbackURL: String
    
    public init(clientID: String, secretKey: String, callbackURL: String) {
        self.clientID = clientID
        self.secretKey = secretKey
        self.callbackURL = callbackURL
    }
}

public struct AccessTokenData: Codable {
    public let aud: [String]
    public let scp: [String]
    public let jti: String
    public let iat: Int64
    public let kid: String
    public let tier: String
    public let owner: String
    public let exp: Int64
    public let iss: String
    public let sub: String
    public let tenant: String
    public let azp: String
    public let region: String
    
    public var characterID: String {
        get {
            return sub.split(separator: ":").last?.lowercased() ?? ""
        }
    }
}
