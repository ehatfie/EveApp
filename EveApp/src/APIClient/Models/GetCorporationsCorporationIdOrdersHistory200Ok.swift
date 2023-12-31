//
// GetCorporationsCorporationIdOrdersHistory200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCorporationsCorporationIdOrdersHistory200Ok: Codable {

    public enum ModelRange: String, Codable { 
        case _1 = "1"
        case _10 = "10"
        case _2 = "2"
        case _20 = "20"
        case _3 = "3"
        case _30 = "30"
        case _4 = "4"
        case _40 = "40"
        case _5 = "5"
        case region = "region"
        case solarsystem = "solarsystem"
        case station = "station"
    }
    public enum State: String, Codable { 
        case cancelled = "cancelled"
        case expired = "expired"
    }
    /** Number of days the order was valid for (starting from the issued date). An order expires at time issued + duration */
    public var duration: Int
    /** For buy orders, the amount of ISK in escrow */
    public var escrow: Double?
    /** True if the order is a bid (buy) order */
    public var isBuyOrder: Bool?
    /** Date and time when this order was issued */
    public var issued: Date
    /** The character who issued this order */
    public var issuedBy: Int?
    /** ID of the location where order was placed */
    public var locationId: Int64
    /** For buy orders, the minimum quantity that will be accepted in a matching sell order */
    public var minVolume: Int?
    /** Unique order ID */
    public var orderId: Int64
    /** Cost per unit for this order */
    public var price: Double
    /** Valid order range, numbers are ranges in jumps */
    public var range: ModelRange
    /** ID of the region where order was placed */
    public var regionId: Int
    /** Current order state */
    public var state: State
    /** The type ID of the item transacted in this order */
    public var typeId: Int
    /** Quantity of items still required or offered */
    public var volumeRemain: Int
    /** Quantity of items required or offered at time order was placed */
    public var volumeTotal: Int
    /** The corporation wallet division used for this order */
    public var walletDivision: Int

    public init(duration: Int, escrow: Double? = nil, isBuyOrder: Bool? = nil, issued: Date, issuedBy: Int? = nil, locationId: Int64, minVolume: Int? = nil, orderId: Int64, price: Double, range: ModelRange, regionId: Int, state: State, typeId: Int, volumeRemain: Int, volumeTotal: Int, walletDivision: Int) {
        self.duration = duration
        self.escrow = escrow
        self.isBuyOrder = isBuyOrder
        self.issued = issued
        self.issuedBy = issuedBy
        self.locationId = locationId
        self.minVolume = minVolume
        self.orderId = orderId
        self.price = price
        self.range = range
        self.regionId = regionId
        self.state = state
        self.typeId = typeId
        self.volumeRemain = volumeRemain
        self.volumeTotal = volumeTotal
        self.walletDivision = walletDivision
    }

    public enum CodingKeys: String, CodingKey { 
        case duration
        case escrow
        case isBuyOrder = "is_buy_order"
        case issued
        case issuedBy = "issued_by"
        case locationId = "location_id"
        case minVolume = "min_volume"
        case orderId = "order_id"
        case price
        case range
        case regionId = "region_id"
        case state
        case typeId = "type_id"
        case volumeRemain = "volume_remain"
        case volumeTotal = "volume_total"
        case walletDivision = "wallet_division"
    }

}
