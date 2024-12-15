//
// GetCorporationsCorporationIdStructuresService.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** service object */

public struct GetCorporationsCorporationIdStructuresService: Codable {

    public enum State: String, Codable { 
        case online = "online"
        case offline = "offline"
        case cleanup = "cleanup"
    }
    /** name string */
    public var name: String
    /** state string */
    public var state: State

    public init(name: String, state: State) {
        self.name = name
        self.state = state
    }


}