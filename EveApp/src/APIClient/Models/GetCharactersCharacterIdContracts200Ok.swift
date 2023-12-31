//
// GetCharactersCharacterIdContracts200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCharactersCharacterIdContracts200Ok: Codable {

    public enum Availability: String, Codable { 
        case _public = "public"
        case personal = "personal"
        case corporation = "corporation"
        case alliance = "alliance"
    }
    public enum Status: String, Codable { 
        case outstanding = "outstanding"
        case inProgress = "in_progress"
        case finishedIssuer = "finished_issuer"
        case finishedContractor = "finished_contractor"
        case finished = "finished"
        case cancelled = "cancelled"
        case rejected = "rejected"
        case failed = "failed"
        case deleted = "deleted"
        case reversed = "reversed"
    }
    public enum ModelType: String, Codable { 
        case unknown = "unknown"
        case itemExchange = "item_exchange"
        case auction = "auction"
        case courier = "courier"
        case loan = "loan"
    }
    /** Who will accept the contract */
    public var acceptorId: Int
    /** ID to whom the contract is assigned, can be alliance, corporation or character ID */
    public var assigneeId: Int
    /** To whom the contract is available */
    public var availability: Availability
    /** Buyout price (for Auctions only) */
    public var buyout: Double?
    /** Collateral price (for Couriers only) */
    public var collateral: Double?
    /** contract_id integer */
    public var contractId: Int
    /** Date of confirmation of contract */
    public var dateAccepted: Date?
    /** Date of completed of contract */
    public var dateCompleted: Date?
    /** Expiration date of the contract */
    public var dateExpired: Date
    /** Сreation date of the contract */
    public var dateIssued: Date
    /** Number of days to perform the contract */
    public var daysToComplete: Int?
    /** End location ID (for Couriers contract) */
    public var endLocationId: Int64?
    /** true if the contract was issued on behalf of the issuer&#x27;s corporation */
    public var forCorporation: Bool
    /** Character&#x27;s corporation ID for the issuer */
    public var issuerCorporationId: Int
    /** Character ID for the issuer */
    public var issuerId: Int
    /** Price of contract (for ItemsExchange and Auctions) */
    public var price: Double?
    /** Remuneration for contract (for Couriers only) */
    public var reward: Double?
    /** Start location ID (for Couriers contract) */
    public var startLocationId: Int64?
    /** Status of the the contract */
    public var status: Status
    /** Title of the contract */
    public var title: String?
    /** Type of the contract */
    public var type: ModelType
    /** Volume of items in the contract */
    public var volume: Double?

    public init(acceptorId: Int, assigneeId: Int, availability: Availability, buyout: Double? = nil, collateral: Double? = nil, contractId: Int, dateAccepted: Date? = nil, dateCompleted: Date? = nil, dateExpired: Date, dateIssued: Date, daysToComplete: Int? = nil, endLocationId: Int64? = nil, forCorporation: Bool, issuerCorporationId: Int, issuerId: Int, price: Double? = nil, reward: Double? = nil, startLocationId: Int64? = nil, status: Status, title: String? = nil, type: ModelType, volume: Double? = nil) {
        self.acceptorId = acceptorId
        self.assigneeId = assigneeId
        self.availability = availability
        self.buyout = buyout
        self.collateral = collateral
        self.contractId = contractId
        self.dateAccepted = dateAccepted
        self.dateCompleted = dateCompleted
        self.dateExpired = dateExpired
        self.dateIssued = dateIssued
        self.daysToComplete = daysToComplete
        self.endLocationId = endLocationId
        self.forCorporation = forCorporation
        self.issuerCorporationId = issuerCorporationId
        self.issuerId = issuerId
        self.price = price
        self.reward = reward
        self.startLocationId = startLocationId
        self.status = status
        self.title = title
        self.type = type
        self.volume = volume
    }

    public enum CodingKeys: String, CodingKey { 
        case acceptorId = "acceptor_id"
        case assigneeId = "assignee_id"
        case availability
        case buyout
        case collateral
        case contractId = "contract_id"
        case dateAccepted = "date_accepted"
        case dateCompleted = "date_completed"
        case dateExpired = "date_expired"
        case dateIssued = "date_issued"
        case daysToComplete = "days_to_complete"
        case endLocationId = "end_location_id"
        case forCorporation = "for_corporation"
        case issuerCorporationId = "issuer_corporation_id"
        case issuerId = "issuer_id"
        case price
        case reward
        case startLocationId = "start_location_id"
        case status
        case title
        case type
        case volume
    }

}
