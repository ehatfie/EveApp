//
// GetCorporationsCorporationIdStructures200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCorporationsCorporationIdStructures200Ok: Codable {

    public enum State: String, Codable { 
        case anchorVulnerable = "anchor_vulnerable"
        case anchoring = "anchoring"
        case armorReinforce = "armor_reinforce"
        case armorVulnerable = "armor_vulnerable"
        case deployVulnerable = "deploy_vulnerable"
        case fittingInvulnerable = "fitting_invulnerable"
        case hullReinforce = "hull_reinforce"
        case hullVulnerable = "hull_vulnerable"
        case onlineDeprecated = "online_deprecated"
        case onliningVulnerable = "onlining_vulnerable"
        case shieldVulnerable = "shield_vulnerable"
        case unanchored = "unanchored"
        case unknown = "unknown"
    }
    /** ID of the corporation that owns the structure */
    public var corporationId: Int
    /** Date on which the structure will run out of fuel */
    public var fuelExpires: Date?
    /** The structure name */
    public var name: String?
    /** The date and time when the structure&#x27;s newly requested reinforcement times (e.g. next_reinforce_hour and next_reinforce_day) will take effect */
    public var nextReinforceApply: Date?
    /** The requested change to reinforce_hour that will take effect at the time shown by next_reinforce_apply */
    public var nextReinforceHour: Int?
    /** The id of the ACL profile for this citadel */
    public var profileId: Int
    /** The hour of day that determines the four hour window when the structure will randomly exit its reinforcement periods and become vulnerable to attack against its armor and/or hull. The structure will become vulnerable at a random time that is +/- 2 hours centered on the value of this property */
    public var reinforceHour: Int?
    /** Contains a list of service upgrades, and their state */
    public var services: [GetCorporationsCorporationIdStructuresService]?
    /** state string */
    public var state: State
    /** Date at which the structure will move to it&#x27;s next state */
    public var stateTimerEnd: Date?
    /** Date at which the structure entered it&#x27;s current state */
    public var stateTimerStart: Date?
    /** The Item ID of the structure */
    public var structureId: Int64
    /** The solar system the structure is in */
    public var systemId: Int
    /** The type id of the structure */
    public var typeId: Int
    /** Date at which the structure will unanchor */
    public var unanchorsAt: Date?

    public init(corporationId: Int, fuelExpires: Date? = nil, name: String? = nil, nextReinforceApply: Date? = nil, nextReinforceHour: Int? = nil, profileId: Int, reinforceHour: Int? = nil, services: [GetCorporationsCorporationIdStructuresService]? = nil, state: State, stateTimerEnd: Date? = nil, stateTimerStart: Date? = nil, structureId: Int64, systemId: Int, typeId: Int, unanchorsAt: Date? = nil) {
        self.corporationId = corporationId
        self.fuelExpires = fuelExpires
        self.name = name
        self.nextReinforceApply = nextReinforceApply
        self.nextReinforceHour = nextReinforceHour
        self.profileId = profileId
        self.reinforceHour = reinforceHour
        self.services = services
        self.state = state
        self.stateTimerEnd = stateTimerEnd
        self.stateTimerStart = stateTimerStart
        self.structureId = structureId
        self.systemId = systemId
        self.typeId = typeId
        self.unanchorsAt = unanchorsAt
    }

    public enum CodingKeys: String, CodingKey { 
        case corporationId = "corporation_id"
        case fuelExpires = "fuel_expires"
        case name
        case nextReinforceApply = "next_reinforce_apply"
        case nextReinforceHour = "next_reinforce_hour"
        case profileId = "profile_id"
        case reinforceHour = "reinforce_hour"
        case services
        case state
        case stateTimerEnd = "state_timer_end"
        case stateTimerStart = "state_timer_start"
        case structureId = "structure_id"
        case systemId = "system_id"
        case typeId = "type_id"
        case unanchorsAt = "unanchors_at"
    }

}
