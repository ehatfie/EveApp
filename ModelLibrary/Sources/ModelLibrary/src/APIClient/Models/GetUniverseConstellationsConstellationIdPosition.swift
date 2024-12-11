//
// GetUniverseConstellationsConstellationIdPosition.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** position object */

public struct GetUniverseConstellationsConstellationIdPosition: Codable {

    /** x number */
    public var x: Double
    /** y number */
    public var y: Double
    /** z number */
    public var z: Double

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }


}
