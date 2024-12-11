//
// PostCharactersCharacterIdAssetsLocations200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct PostCharactersCharacterIdAssetsLocations200Ok: Codable {

    /** item_id integer */
    public var itemId: Int64
    public var position: PostCharactersCharacterIdAssetsLocationsPosition

    public init(itemId: Int64, position: PostCharactersCharacterIdAssetsLocationsPosition) {
        self.itemId = itemId
        self.position = position
    }

    public enum CodingKeys: String, CodingKey { 
        case itemId = "item_id"
        case position
    }

}
