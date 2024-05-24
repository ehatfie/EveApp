//
//  AccessTokenResponse.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/27/23.
//

import Foundation

struct AccessTokenData: Codable {
    let aud: [String]
    let scp: [String]
    let jti: String
    let iat: Int64
    let kid: String
    let tier: String
    let owner: String
    let exp: Int64
    let iss: String
    let sub: String
    let tenant: String
    let azp: String
    let region: String
    
    var characterID: String {
        get {
            return sub.split(separator: ":").last?.lowercased() ?? ""
        }
    }
}
