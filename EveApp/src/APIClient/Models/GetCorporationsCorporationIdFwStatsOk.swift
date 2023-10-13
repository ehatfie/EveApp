//
// GetCorporationsCorporationIdFwStatsOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCorporationsCorporationIdFwStatsOk: Codable {

    /** The enlistment date of the given corporation into faction warfare. Will not be included if corporation is not enlisted in faction warfare */
    public var enlistedOn: Date?
    /** The faction the given corporation is enlisted to fight for. Will not be included if corporation is not enlisted in faction warfare */
    public var factionId: Int?
    public var kills: GetCorporationsCorporationIdFwStatsKills
    /** How many pilots the enlisted corporation has. Will not be included if corporation is not enlisted in faction warfare */
    public var pilots: Int?
    public var victoryPoints: GetCorporationsCorporationIdFwStatsVictoryPoints

    public init(enlistedOn: Date? = nil, factionId: Int? = nil, kills: GetCorporationsCorporationIdFwStatsKills, pilots: Int? = nil, victoryPoints: GetCorporationsCorporationIdFwStatsVictoryPoints) {
        self.enlistedOn = enlistedOn
        self.factionId = factionId
        self.kills = kills
        self.pilots = pilots
        self.victoryPoints = victoryPoints
    }

    public enum CodingKeys: String, CodingKey { 
        case enlistedOn = "enlisted_on"
        case factionId = "faction_id"
        case kills
        case pilots
        case victoryPoints = "victory_points"
    }

}
