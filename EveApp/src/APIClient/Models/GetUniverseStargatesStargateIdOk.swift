//
// GetUniverseStargatesStargateIdOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetUniverseStargatesStargateIdOk: Codable {

    public var destination: GetUniverseStargatesStargateIdDestination
    /** name string */
    public var name: String
    public var position: GetUniverseStargatesStargateIdPosition
    /** stargate_id integer */
    public var stargateId: Int
    /** The solar system this stargate is in */
    public var systemId: Int
    /** type_id integer */
    public var typeId: Int

    public init(destination: GetUniverseStargatesStargateIdDestination, name: String, position: GetUniverseStargatesStargateIdPosition, stargateId: Int, systemId: Int, typeId: Int) {
        self.destination = destination
        self.name = name
        self.position = position
        self.stargateId = stargateId
        self.systemId = systemId
        self.typeId = typeId
    }

    public enum CodingKeys: String, CodingKey { 
        case destination
        case name
        case position
        case stargateId = "stargate_id"
        case systemId = "system_id"
        case typeId = "type_id"
    }

}
