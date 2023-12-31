//
// GetCharactersCharacterIdMedals200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCharactersCharacterIdMedals200Ok: Codable {

    public enum Status: String, Codable { 
        case _public = "public"
        case _private = "private"
    }
    /** corporation_id integer */
    public var corporationId: Int
    /** date string */
    public var date: Date
    /** description string */
    public var _description: String
    /** graphics array */
    public var graphics: [GetCharactersCharacterIdMedalsGraphic]
    /** issuer_id integer */
    public var issuerId: Int
    /** medal_id integer */
    public var medalId: Int
    /** reason string */
    public var reason: String
    /** status string */
    public var status: Status
    /** title string */
    public var title: String

    public init(corporationId: Int, date: Date, _description: String, graphics: [GetCharactersCharacterIdMedalsGraphic], issuerId: Int, medalId: Int, reason: String, status: Status, title: String) {
        self.corporationId = corporationId
        self.date = date
        self._description = _description
        self.graphics = graphics
        self.issuerId = issuerId
        self.medalId = medalId
        self.reason = reason
        self.status = status
        self.title = title
    }

    public enum CodingKeys: String, CodingKey { 
        case corporationId = "corporation_id"
        case date
        case _description = "description"
        case graphics
        case issuerId = "issuer_id"
        case medalId = "medal_id"
        case reason
        case status
        case title
    }

}
