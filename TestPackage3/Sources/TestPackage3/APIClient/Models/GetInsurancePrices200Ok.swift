//
// GetInsurancePrices200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetInsurancePrices200Ok: Codable {

    /** A list of a available insurance levels for this ship type */
    public var levels: [GetInsurancePricesLevel]
    /** type_id integer */
    public var typeId: Int

    public init(levels: [GetInsurancePricesLevel], typeId: Int) {
        self.levels = levels
        self.typeId = typeId
    }

    public enum CodingKeys: String, CodingKey { 
        case levels
        case typeId = "type_id"
    }

}