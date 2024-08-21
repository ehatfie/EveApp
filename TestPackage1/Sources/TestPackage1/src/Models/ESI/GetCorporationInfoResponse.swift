//
//  GetCorporationInfoResponse.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/5/24.
//

import Foundation

public struct GetCorporationInfoResponse: Codable {

    /** ID of the alliance that corporation is a member of, if any */
    public var allianceId: Int?
    /** ceo_id integer */
    public var ceoId: Int
    /** creator_id integer */
    public var creatorId: Int
    /** date_founded string */
    public var dateFounded: String?
    /** description string */
    public var _description: String?
    /** faction_id integer */
    public var factionId: Int?
    /** home_station_id integer */
    public var homeStationId: Int?
    /** member_count integer */
    public var memberCount: Int
    /** the full name of the corporation */
    public var name: String
    /** shares integer */
    public var shares: Int64?
    /** tax_rate number */
    public var taxRate: Float
    /** the short name of the corporation */
    public var ticker: String
    /** url string */
    public var url: String?
    /** war_eligible boolean */
    public var warEligible: Bool?

    public init(allianceId: Int? = nil, ceoId: Int, creatorId: Int, dateFounded: String? = nil, _description: String? = nil, factionId: Int? = nil, homeStationId: Int? = nil, memberCount: Int, name: String, shares: Int64? = nil, taxRate: Float, ticker: String, url: String? = nil, warEligible: Bool? = nil) {
        self.allianceId = allianceId
        self.ceoId = ceoId
        self.creatorId = creatorId
        self.dateFounded = dateFounded
        self._description = _description
        self.factionId = factionId
        self.homeStationId = homeStationId
        self.memberCount = memberCount
        self.name = name
        self.shares = shares
        self.taxRate = taxRate
        self.ticker = ticker
        self.url = url
        self.warEligible = warEligible
    }

    public enum CodingKeys: String, CodingKey {
        case allianceId = "alliance_id"
        case ceoId = "ceo_id"
        case creatorId = "creator_id"
        case dateFounded = "date_founded"
        case _description = "description"
        case factionId = "faction_id"
        case homeStationId = "home_station_id"
        case memberCount = "member_count"
        case name
        case shares
        case taxRate = "tax_rate"
        case ticker
        case url
        case warEligible = "war_eligible"
    }

}
