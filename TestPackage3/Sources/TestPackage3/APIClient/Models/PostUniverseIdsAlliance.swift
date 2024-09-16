//
// PostUniverseIdsAlliance.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** alliance object */

public struct PostUniverseIdsAlliance: Codable {

    /** id integer */
    public var _id: Int?
    /** name string */
    public var name: String?

    public init(_id: Int? = nil, name: String? = nil) {
        self._id = _id
        self.name = name
    }

    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case name
    }

}