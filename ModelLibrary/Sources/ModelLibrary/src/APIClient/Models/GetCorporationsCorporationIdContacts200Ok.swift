//
// GetCorporationsCorporationIdContacts200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCorporationsCorporationIdContacts200Ok: Codable {

    public enum ContactType: String, Codable { 
        case character = "character"
        case corporation = "corporation"
        case alliance = "alliance"
        case faction = "faction"
    }
    /** contact_id integer */
    public var contactId: Int
    /** contact_type string */
    public var contactType: ContactType
    /** Whether this contact is being watched */
    public var isWatched: Bool?
    /** label_ids array */
    public var labelIds: [Int64]?
    /** Standing of the contact */
    public var standing: Float

    public init(contactId: Int, contactType: ContactType, isWatched: Bool? = nil, labelIds: [Int64]? = nil, standing: Float) {
        self.contactId = contactId
        self.contactType = contactType
        self.isWatched = isWatched
        self.labelIds = labelIds
        self.standing = standing
    }

    public enum CodingKeys: String, CodingKey { 
        case contactId = "contact_id"
        case contactType = "contact_type"
        case isWatched = "is_watched"
        case labelIds = "label_ids"
        case standing
    }

}
