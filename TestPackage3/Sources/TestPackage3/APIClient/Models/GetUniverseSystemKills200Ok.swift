//
// GetUniverseSystemKills200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetUniverseSystemKills200Ok: Codable {

    /** Number of NPC ships killed in this system */
    public var npcKills: Int
    /** Number of pods killed in this system */
    public var podKills: Int
    /** Number of player ships killed in this system */
    public var shipKills: Int
    /** system_id integer */
    public var systemId: Int

    public init(npcKills: Int, podKills: Int, shipKills: Int, systemId: Int) {
        self.npcKills = npcKills
        self.podKills = podKills
        self.shipKills = shipKills
        self.systemId = systemId
    }

    public enum CodingKeys: String, CodingKey { 
        case npcKills = "npc_kills"
        case podKills = "pod_kills"
        case shipKills = "ship_kills"
        case systemId = "system_id"
    }

}