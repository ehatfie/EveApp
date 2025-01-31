//
// GetUniverseSchematicsSchematicIdOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetUniverseSchematicsSchematicIdOk: Codable {

    /** Time in seconds to process a run */
    public var cycleTime: Int
    /** schematic_name string */
    public var schematicName: String

    public init(cycleTime: Int, schematicName: String) {
        self.cycleTime = cycleTime
        self.schematicName = schematicName
    }

    public enum CodingKeys: String, CodingKey { 
        case cycleTime = "cycle_time"
        case schematicName = "schematic_name"
    }

}
