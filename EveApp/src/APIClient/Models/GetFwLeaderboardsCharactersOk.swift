//
// GetFwLeaderboardsCharactersOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetFwLeaderboardsCharactersOk: Codable {

    public var kills: GetFwLeaderboardsCharactersKills
    public var victoryPoints: GetFwLeaderboardsCharactersVictoryPoints

    public init(kills: GetFwLeaderboardsCharactersKills, victoryPoints: GetFwLeaderboardsCharactersVictoryPoints) {
        self.kills = kills
        self.victoryPoints = victoryPoints
    }

    public enum CodingKeys: String, CodingKey { 
        case kills
        case victoryPoints = "victory_points"
    }

}
