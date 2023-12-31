//
// GetCharactersCharacterIdBookmarks200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCharactersCharacterIdBookmarks200Ok: Codable {

    /** bookmark_id integer */
    public var bookmarkId: Int
    public var coordinates: GetCharactersCharacterIdBookmarksCoordinates?
    /** created string */
    public var created: Date
    /** creator_id integer */
    public var creatorId: Int
    /** folder_id integer */
    public var folderId: Int?
    public var item: GetCharactersCharacterIdBookmarksItem?
    /** label string */
    public var label: String
    /** location_id integer */
    public var locationId: Int
    /** notes string */
    public var notes: String

    public init(bookmarkId: Int, coordinates: GetCharactersCharacterIdBookmarksCoordinates? = nil, created: Date, creatorId: Int, folderId: Int? = nil, item: GetCharactersCharacterIdBookmarksItem? = nil, label: String, locationId: Int, notes: String) {
        self.bookmarkId = bookmarkId
        self.coordinates = coordinates
        self.created = created
        self.creatorId = creatorId
        self.folderId = folderId
        self.item = item
        self.label = label
        self.locationId = locationId
        self.notes = notes
    }

    public enum CodingKeys: String, CodingKey { 
        case bookmarkId = "bookmark_id"
        case coordinates
        case created
        case creatorId = "creator_id"
        case folderId = "folder_id"
        case item
        case label
        case locationId = "location_id"
        case notes
    }

}
