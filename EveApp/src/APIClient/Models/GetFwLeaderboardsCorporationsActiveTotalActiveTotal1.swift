//
// GetFwLeaderboardsCorporationsActiveTotalActiveTotal1.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** active_total object */

public struct GetFwLeaderboardsCorporationsActiveTotalActiveTotal1: Codable {

    /** Amount of victory points */
    public var amount: Int?
    /** corporation_id integer */
    public var corporationId: Int?

    public init(amount: Int? = nil, corporationId: Int? = nil) {
        self.amount = amount
        self.corporationId = corporationId
    }

    public enum CodingKeys: String, CodingKey { 
        case amount
        case corporationId = "corporation_id"
    }

}
