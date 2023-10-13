//
// GetSovereigntyStructures200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetSovereigntyStructures200Ok: Codable {

    /** The alliance that owns the structure.  */
    public var allianceId: Int
    /** Solar system in which the structure is located.  */
    public var solarSystemId: Int
    /** Unique item ID for this structure. */
    public var structureId: Int64
    /** A reference to the type of structure this is.  */
    public var structureTypeId: Int
    /** The occupancy level for the next or current vulnerability window. This takes into account all development indexes and capital system bonuses. Also known as Activity Defense Multiplier from in the client. It increases the time that attackers must spend using their entosis links on the structure.  */
    public var vulnerabilityOccupancyLevel: Float?
    /** The time at which the next or current vulnerability window ends. At the end of a vulnerability window the next window is recalculated and locked in along with the vulnerabilityOccupancyLevel. If the structure is not in 100% entosis control of the defender, it will go in to &#x27;overtime&#x27; and stay vulnerable for as long as that situation persists. Only once the defenders have 100% entosis control and has the vulnerableEndTime passed does the vulnerability interval expire and a new one is calculated.  */
    public var vulnerableEndTime: Date?
    /** The next time at which the structure will become vulnerable. Or the start time of the current window if current time is between this and vulnerableEndTime.  */
    public var vulnerableStartTime: Date?

    public init(allianceId: Int, solarSystemId: Int, structureId: Int64, structureTypeId: Int, vulnerabilityOccupancyLevel: Float? = nil, vulnerableEndTime: Date? = nil, vulnerableStartTime: Date? = nil) {
        self.allianceId = allianceId
        self.solarSystemId = solarSystemId
        self.structureId = structureId
        self.structureTypeId = structureTypeId
        self.vulnerabilityOccupancyLevel = vulnerabilityOccupancyLevel
        self.vulnerableEndTime = vulnerableEndTime
        self.vulnerableStartTime = vulnerableStartTime
    }

    public enum CodingKeys: String, CodingKey { 
        case allianceId = "alliance_id"
        case solarSystemId = "solar_system_id"
        case structureId = "structure_id"
        case structureTypeId = "structure_type_id"
        case vulnerabilityOccupancyLevel = "vulnerability_occupancy_level"
        case vulnerableEndTime = "vulnerable_end_time"
        case vulnerableStartTime = "vulnerable_start_time"
    }

}
