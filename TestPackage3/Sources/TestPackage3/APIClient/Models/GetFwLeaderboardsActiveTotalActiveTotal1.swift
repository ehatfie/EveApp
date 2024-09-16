//
// GetFwLeaderboardsActiveTotalActiveTotal1.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** active_total object */

public struct GetFwLeaderboardsActiveTotalActiveTotal1: Codable {

    /** Amount of victory points */
    public var amount: Int?
    /** faction_id integer */
    public var factionId: Int?

    public init(amount: Int? = nil, factionId: Int? = nil) {
        self.amount = amount
        self.factionId = factionId
    }

    public enum CodingKeys: String, CodingKey { 
        case amount
        case factionId = "faction_id"
    }

}