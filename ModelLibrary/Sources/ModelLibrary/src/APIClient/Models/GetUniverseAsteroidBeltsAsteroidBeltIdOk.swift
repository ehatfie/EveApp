//
// GetUniverseAsteroidBeltsAsteroidBeltIdOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetUniverseAsteroidBeltsAsteroidBeltIdOk: Codable {

    /** name string */
    public var name: String
    public var position: GetUniverseAsteroidBeltsAsteroidBeltIdPosition
    /** The solar system this asteroid belt is in */
    public var systemId: Int

    public init(name: String, position: GetUniverseAsteroidBeltsAsteroidBeltIdPosition, systemId: Int) {
        self.name = name
        self.position = position
        self.systemId = systemId
    }

    public enum CodingKeys: String, CodingKey { 
        case name
        case position
        case systemId = "system_id"
    }

}