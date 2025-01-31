//
// GetUniverseRegionsRegionIdOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetUniverseRegionsRegionIdOk: Codable {

    /** constellations array */
    public var constellations: [Int]
    /** description string */
    public var _description: String?
    /** name string */
    public var name: String
    /** region_id integer */
    public var regionId: Int

    public init(constellations: [Int], _description: String? = nil, name: String, regionId: Int) {
        self.constellations = constellations
        self._description = _description
        self.name = name
        self.regionId = regionId
    }

    public enum CodingKeys: String, CodingKey { 
        case constellations
        case _description = "description"
        case name
        case regionId = "region_id"
    }

}
