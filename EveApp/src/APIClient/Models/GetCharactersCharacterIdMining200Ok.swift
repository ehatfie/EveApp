//
// GetCharactersCharacterIdMining200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCharactersCharacterIdMining200Ok: Codable {

    /** date string */
    public var date: Date
    /** quantity integer */
    public var quantity: Int64
    /** solar_system_id integer */
    public var solarSystemId: Int
    /** type_id integer */
    public var typeId: Int

    public init(date: Date, quantity: Int64, solarSystemId: Int, typeId: Int) {
        self.date = date
        self.quantity = quantity
        self.solarSystemId = solarSystemId
        self.typeId = typeId
    }

    public enum CodingKeys: String, CodingKey { 
        case date
        case quantity
        case solarSystemId = "solar_system_id"
        case typeId = "type_id"
    }

}
