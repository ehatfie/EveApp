//
// PostFleetsFleetIdMembersInvitation.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** invitation object */

public struct PostFleetsFleetIdMembersInvitation: Codable {

    public enum Role: String, Codable { 
        case fleetCommander = "fleet_commander"
        case wingCommander = "wing_commander"
        case squadCommander = "squad_commander"
        case squadMember = "squad_member"
    }
    /** The character you want to invite */
    public var characterId: Int
    /** If a character is invited with the &#x60;fleet_commander&#x60; role, neither &#x60;wing_id&#x60; or &#x60;squad_id&#x60; should be specified. If a character is invited with the &#x60;wing_commander&#x60; role, only &#x60;wing_id&#x60; should be specified. If a character is invited with the &#x60;squad_commander&#x60; role, both &#x60;wing_id&#x60; and &#x60;squad_id&#x60; should be specified. If a character is invited with the &#x60;squad_member&#x60; role, &#x60;wing_id&#x60; and &#x60;squad_id&#x60; should either both be specified or not specified at all. If they aren’t specified, the invited character will join any squad with available positions. */
    public var role: Role
    /** squad_id integer */
    public var squadId: Int64?
    /** wing_id integer */
    public var wingId: Int64?

    public init(characterId: Int, role: Role, squadId: Int64? = nil, wingId: Int64? = nil) {
        self.characterId = characterId
        self.role = role
        self.squadId = squadId
        self.wingId = wingId
    }

    public enum CodingKeys: String, CodingKey { 
        case characterId = "character_id"
        case role
        case squadId = "squad_id"
        case wingId = "wing_id"
    }

}
