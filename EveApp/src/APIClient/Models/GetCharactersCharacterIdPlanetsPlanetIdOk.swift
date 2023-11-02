//
// GetCharactersCharacterIdPlanetsPlanetIdOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCharactersCharacterIdPlanetsPlanetIdOk: Codable {

    /** links array */
    public var links: [GetCharactersCharacterIdPlanetsPlanetIdLink]
    /** pins array */
    public var pins: [GetCharactersCharacterIdPlanetsPlanetIdPin]
    /** routes array */
    public var routes: [GetCharactersCharacterIdPlanetsPlanetIdRoute]

    public init(links: [GetCharactersCharacterIdPlanetsPlanetIdLink], pins: [GetCharactersCharacterIdPlanetsPlanetIdPin], routes: [GetCharactersCharacterIdPlanetsPlanetIdRoute]) {
        self.links = links
        self.pins = pins
        self.routes = routes
    }


}
