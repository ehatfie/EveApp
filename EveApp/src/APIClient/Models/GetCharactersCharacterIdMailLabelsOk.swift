//
// GetCharactersCharacterIdMailLabelsOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCharactersCharacterIdMailLabelsOk: Codable {

    /** labels array */
    public var labels: [GetCharactersCharacterIdMailLabelsLabel]?
    /** total_unread_count integer */
    public var totalUnreadCount: Int?

    public init(labels: [GetCharactersCharacterIdMailLabelsLabel]? = nil, totalUnreadCount: Int? = nil) {
        self.labels = labels
        self.totalUnreadCount = totalUnreadCount
    }

    public enum CodingKeys: String, CodingKey { 
        case labels
        case totalUnreadCount = "total_unread_count"
    }

}
