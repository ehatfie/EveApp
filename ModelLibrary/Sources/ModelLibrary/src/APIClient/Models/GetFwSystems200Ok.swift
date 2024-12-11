//
// GetFwSystems200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetFwSystems200Ok: Codable {

    public enum Contested: String, Codable { 
        case captured = "captured"
        case contested = "contested"
        case uncontested = "uncontested"
        case vulnerable = "vulnerable"
    }
    /** contested string */
    public var contested: Contested
    /** occupier_faction_id integer */
    public var occupierFactionId: Int
    /** owner_faction_id integer */
    public var ownerFactionId: Int
    /** solar_system_id integer */
    public var solarSystemId: Int
    /** victory_points integer */
    public var victoryPoints: Int
    /** victory_points_threshold integer */
    public var victoryPointsThreshold: Int

    public init(contested: Contested, occupierFactionId: Int, ownerFactionId: Int, solarSystemId: Int, victoryPoints: Int, victoryPointsThreshold: Int) {
        self.contested = contested
        self.occupierFactionId = occupierFactionId
        self.ownerFactionId = ownerFactionId
        self.solarSystemId = solarSystemId
        self.victoryPoints = victoryPoints
        self.victoryPointsThreshold = victoryPointsThreshold
    }

    public enum CodingKeys: String, CodingKey { 
        case contested
        case occupierFactionId = "occupier_faction_id"
        case ownerFactionId = "owner_faction_id"
        case solarSystemId = "solar_system_id"
        case victoryPoints = "victory_points"
        case victoryPointsThreshold = "victory_points_threshold"
    }

}
