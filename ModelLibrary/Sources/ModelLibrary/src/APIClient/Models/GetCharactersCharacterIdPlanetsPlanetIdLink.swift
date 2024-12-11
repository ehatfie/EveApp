//
// GetCharactersCharacterIdPlanetsPlanetIdLink.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** link object */

public struct GetCharactersCharacterIdPlanetsPlanetIdLink: Codable {

    /** destination_pin_id integer */
    public var destinationPinId: Int64
    /** link_level integer */
    public var linkLevel: Int
    /** source_pin_id integer */
    public var sourcePinId: Int64

    public init(destinationPinId: Int64, linkLevel: Int, sourcePinId: Int64) {
        self.destinationPinId = destinationPinId
        self.linkLevel = linkLevel
        self.sourcePinId = sourcePinId
    }

    public enum CodingKeys: String, CodingKey { 
        case destinationPinId = "destination_pin_id"
        case linkLevel = "link_level"
        case sourcePinId = "source_pin_id"
    }

}
