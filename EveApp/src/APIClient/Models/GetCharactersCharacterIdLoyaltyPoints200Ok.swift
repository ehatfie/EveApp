//
// GetCharactersCharacterIdLoyaltyPoints200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCharactersCharacterIdLoyaltyPoints200Ok: Codable {

    /** corporation_id integer */
    public var corporationId: Int
    /** loyalty_points integer */
    public var loyaltyPoints: Int

    public init(corporationId: Int, loyaltyPoints: Int) {
        self.corporationId = corporationId
        self.loyaltyPoints = loyaltyPoints
    }

    public enum CodingKeys: String, CodingKey { 
        case corporationId = "corporation_id"
        case loyaltyPoints = "loyalty_points"
    }

}
