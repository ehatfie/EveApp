//
// GetUniversePlanetsPlanetIdOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetUniversePlanetsPlanetIdOk: Codable {

    /** name string */
    public var name: String
    /** planet_id integer */
    public var planetId: Int
    public var position: GetUniversePlanetsPlanetIdPosition
    /** The solar system this planet is in */
    public var systemId: Int
    /** type_id integer */
    public var typeId: Int

    public init(name: String, planetId: Int, position: GetUniversePlanetsPlanetIdPosition, systemId: Int, typeId: Int) {
        self.name = name
        self.planetId = planetId
        self.position = position
        self.systemId = systemId
        self.typeId = typeId
    }

    public enum CodingKeys: String, CodingKey { 
        case name
        case planetId = "planet_id"
        case position
        case systemId = "system_id"
        case typeId = "type_id"
    }

}
