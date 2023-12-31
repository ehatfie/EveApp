//
// GetCorporationCorporationIdMiningExtractions200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCorporationCorporationIdMiningExtractions200Ok: Codable {

    /** The time at which the chunk being extracted will arrive and can be fractured by the moon mining drill.  */
    public var chunkArrivalTime: Date
    /** The time at which the current extraction was initiated.  */
    public var extractionStartTime: Date
    /** moon_id integer */
    public var moonId: Int
    /** The time at which the chunk being extracted will naturally fracture if it is not first fractured by the moon mining drill.  */
    public var naturalDecayTime: Date
    /** structure_id integer */
    public var structureId: Int64

    public init(chunkArrivalTime: Date, extractionStartTime: Date, moonId: Int, naturalDecayTime: Date, structureId: Int64) {
        self.chunkArrivalTime = chunkArrivalTime
        self.extractionStartTime = extractionStartTime
        self.moonId = moonId
        self.naturalDecayTime = naturalDecayTime
        self.structureId = structureId
    }

    public enum CodingKeys: String, CodingKey { 
        case chunkArrivalTime = "chunk_arrival_time"
        case extractionStartTime = "extraction_start_time"
        case moonId = "moon_id"
        case naturalDecayTime = "natural_decay_time"
        case structureId = "structure_id"
    }

}
