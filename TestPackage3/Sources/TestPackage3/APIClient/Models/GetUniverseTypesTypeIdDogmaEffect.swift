//
// GetUniverseTypesTypeIdDogmaEffect.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** dogma_effect object */

public struct GetUniverseTypesTypeIdDogmaEffect: Codable {

    /** effect_id integer */
    public var effectId: Int
    /** is_default boolean */
    public var isDefault: Bool

    public init(effectId: Int, isDefault: Bool) {
        self.effectId = effectId
        self.isDefault = isDefault
    }

    public enum CodingKeys: String, CodingKey { 
        case effectId = "effect_id"
        case isDefault = "is_default"
    }

}