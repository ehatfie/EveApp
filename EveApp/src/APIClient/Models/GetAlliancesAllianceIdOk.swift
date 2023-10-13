//
// GetAlliancesAllianceIdOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetAlliancesAllianceIdOk: Codable {

    /** ID of the corporation that created the alliance */
    public var creatorCorporationId: Int
    /** ID of the character that created the alliance */
    public var creatorId: Int
    /** date_founded string */
    public var dateFounded: Date
    /** the executor corporation ID, if this alliance is not closed */
    public var executorCorporationId: Int?
    /** Faction ID this alliance is fighting for, if this alliance is enlisted in factional warfare */
    public var factionId: Int?
    /** the full name of the alliance */
    public var name: String
    /** the short name of the alliance */
    public var ticker: String

    public init(creatorCorporationId: Int, creatorId: Int, dateFounded: Date, executorCorporationId: Int? = nil, factionId: Int? = nil, name: String, ticker: String) {
        self.creatorCorporationId = creatorCorporationId
        self.creatorId = creatorId
        self.dateFounded = dateFounded
        self.executorCorporationId = executorCorporationId
        self.factionId = factionId
        self.name = name
        self.ticker = ticker
    }

    public enum CodingKeys: String, CodingKey { 
        case creatorCorporationId = "creator_corporation_id"
        case creatorId = "creator_id"
        case dateFounded = "date_founded"
        case executorCorporationId = "executor_corporation_id"
        case factionId = "faction_id"
        case name
        case ticker
    }

}