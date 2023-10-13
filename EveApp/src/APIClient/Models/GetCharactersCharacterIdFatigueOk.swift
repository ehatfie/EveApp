//
// GetCharactersCharacterIdFatigueOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCharactersCharacterIdFatigueOk: Codable {

    /** Character&#x27;s jump fatigue expiry */
    public var jumpFatigueExpireDate: Date?
    /** Character&#x27;s last jump activation */
    public var lastJumpDate: Date?
    /** Character&#x27;s last jump update */
    public var lastUpdateDate: Date?

    public init(jumpFatigueExpireDate: Date? = nil, lastJumpDate: Date? = nil, lastUpdateDate: Date? = nil) {
        self.jumpFatigueExpireDate = jumpFatigueExpireDate
        self.lastJumpDate = lastJumpDate
        self.lastUpdateDate = lastUpdateDate
    }

    public enum CodingKeys: String, CodingKey { 
        case jumpFatigueExpireDate = "jump_fatigue_expire_date"
        case lastJumpDate = "last_jump_date"
        case lastUpdateDate = "last_update_date"
    }

}