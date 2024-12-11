//
// GetKillmailsKillmailIdKillmailHashItemsItem.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** item object */

public struct GetKillmailsKillmailIdKillmailHashItemsItem: Codable {

    /** flag integer */
    public var flag: Int
    /** item_type_id integer */
    public var itemTypeId: Int
    /** quantity_destroyed integer */
    public var quantityDestroyed: Int64?
    /** quantity_dropped integer */
    public var quantityDropped: Int64?
    /** singleton integer */
    public var singleton: Int

    public init(flag: Int, itemTypeId: Int, quantityDestroyed: Int64? = nil, quantityDropped: Int64? = nil, singleton: Int) {
        self.flag = flag
        self.itemTypeId = itemTypeId
        self.quantityDestroyed = quantityDestroyed
        self.quantityDropped = quantityDropped
        self.singleton = singleton
    }

    public enum CodingKeys: String, CodingKey { 
        case flag
        case itemTypeId = "item_type_id"
        case quantityDestroyed = "quantity_destroyed"
        case quantityDropped = "quantity_dropped"
        case singleton
    }

}