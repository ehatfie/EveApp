//
// GetCharactersCharacterIdFwStatsOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCharactersCharacterIdFwStatsOk: Codable {

    /** The given character&#x27;s current faction rank */
    public var currentRank: Int?
    /** The enlistment date of the given character into faction warfare. Will not be included if character is not enlisted in faction warfare */
    public var enlistedOn: Date?
    /** The faction the given character is enlisted to fight for. Will not be included if character is not enlisted in faction warfare */
    public var factionId: Int?
    /** The given character&#x27;s highest faction rank achieved */
    public var highestRank: Int?
    public var kills: GetCharactersCharacterIdFwStatsKills
    public var victoryPoints: GetCharactersCharacterIdFwStatsVictoryPoints

    public init(currentRank: Int? = nil, enlistedOn: Date? = nil, factionId: Int? = nil, highestRank: Int? = nil, kills: GetCharactersCharacterIdFwStatsKills, victoryPoints: GetCharactersCharacterIdFwStatsVictoryPoints) {
        self.currentRank = currentRank
        self.enlistedOn = enlistedOn
        self.factionId = factionId
        self.highestRank = highestRank
        self.kills = kills
        self.victoryPoints = victoryPoints
    }

    public enum CodingKeys: String, CodingKey { 
        case currentRank = "current_rank"
        case enlistedOn = "enlisted_on"
        case factionId = "faction_id"
        case highestRank = "highest_rank"
        case kills
        case victoryPoints = "victory_points"
    }

}
