//
// GetCharactersCharacterIdWalletTransactions200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** wallet transaction */

public struct GetCharactersCharacterIdWalletTransactions200Ok: Codable {

    /** client_id integer */
    public var clientId: Int
    /** Date and time of transaction */
    public var date: Date
    /** is_buy boolean */
    public var isBuy: Bool
    /** is_personal boolean */
    public var isPersonal: Bool
    /** journal_ref_id integer */
    public var journalRefId: Int64
    /** location_id integer */
    public var locationId: Int64
    /** quantity integer */
    public var quantity: Int
    /** Unique transaction ID */
    public var transactionId: Int64
    /** type_id integer */
    public var typeId: Int
    /** Amount paid per unit */
    public var unitPrice: Double

    public init(clientId: Int, date: Date, isBuy: Bool, isPersonal: Bool, journalRefId: Int64, locationId: Int64, quantity: Int, transactionId: Int64, typeId: Int, unitPrice: Double) {
        self.clientId = clientId
        self.date = date
        self.isBuy = isBuy
        self.isPersonal = isPersonal
        self.journalRefId = journalRefId
        self.locationId = locationId
        self.quantity = quantity
        self.transactionId = transactionId
        self.typeId = typeId
        self.unitPrice = unitPrice
    }

    public enum CodingKeys: String, CodingKey { 
        case clientId = "client_id"
        case date
        case isBuy = "is_buy"
        case isPersonal = "is_personal"
        case journalRefId = "journal_ref_id"
        case locationId = "location_id"
        case quantity
        case transactionId = "transaction_id"
        case typeId = "type_id"
        case unitPrice = "unit_price"
    }

}