//
// PostCharactersCharacterIdAssetsNames200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct PostCharactersCharacterIdAssetsNames200Ok: Codable {

    /** item_id integer */
    public var itemId: Int64
    /** name string */
    public var name: String

    public init(itemId: Int64, name: String) {
        self.itemId = itemId
        self.name = name
    }

    public enum CodingKeys: String, CodingKey { 
        case itemId = "item_id"
        case name
    }

}
