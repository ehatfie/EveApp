////
////  AccessTokenResponse.swift
////  EveApp
////
////  Created by Erik Hatfield on 6/27/23.
////
//
//import Foundation
//
//public struct AccessTokenData: Codable {
//    public let aud: [String]
//    public let scp: [String]
//    public let jti: String
//    public let iat: Int64
//    public let kid: String
//    public let tier: String
//    public let owner: String
//    public let exp: Int64
//    public let iss: String
//    public let sub: String
//    public let tenant: String
//    public let azp: String
//    public let region: String
//    
//    public var characterID: String {
//        get {
//            return sub.split(separator: ":").last?.lowercased() ?? ""
//        }
//    }
//}
