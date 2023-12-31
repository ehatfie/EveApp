//
// GetDogmaEffectsEffectIdOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetDogmaEffectsEffectIdOk: Codable {

    /** description string */
    public var _description: String?
    /** disallow_auto_repeat boolean */
    public var disallowAutoRepeat: Bool?
    /** discharge_attribute_id integer */
    public var dischargeAttributeId: Int?
    /** display_name string */
    public var displayName: String?
    /** duration_attribute_id integer */
    public var durationAttributeId: Int?
    /** effect_category integer */
    public var effectCategory: Int?
    /** effect_id integer */
    public var effectId: Int
    /** electronic_chance boolean */
    public var electronicChance: Bool?
    /** falloff_attribute_id integer */
    public var falloffAttributeId: Int?
    /** icon_id integer */
    public var iconId: Int?
    /** is_assistance boolean */
    public var isAssistance: Bool?
    /** is_offensive boolean */
    public var isOffensive: Bool?
    /** is_warp_safe boolean */
    public var isWarpSafe: Bool?
    /** modifiers array */
    public var modifiers: [GetDogmaEffectsEffectIdModifier]?
    /** name string */
    public var name: String?
    /** post_expression integer */
    public var postExpression: Int?
    /** pre_expression integer */
    public var preExpression: Int?
    /** published boolean */
    public var published: Bool?
    /** range_attribute_id integer */
    public var rangeAttributeId: Int?
    /** range_chance boolean */
    public var rangeChance: Bool?
    /** tracking_speed_attribute_id integer */
    public var trackingSpeedAttributeId: Int?

    public init(_description: String? = nil, disallowAutoRepeat: Bool? = nil, dischargeAttributeId: Int? = nil, displayName: String? = nil, durationAttributeId: Int? = nil, effectCategory: Int? = nil, effectId: Int, electronicChance: Bool? = nil, falloffAttributeId: Int? = nil, iconId: Int? = nil, isAssistance: Bool? = nil, isOffensive: Bool? = nil, isWarpSafe: Bool? = nil, modifiers: [GetDogmaEffectsEffectIdModifier]? = nil, name: String? = nil, postExpression: Int? = nil, preExpression: Int? = nil, published: Bool? = nil, rangeAttributeId: Int? = nil, rangeChance: Bool? = nil, trackingSpeedAttributeId: Int? = nil) {
        self._description = _description
        self.disallowAutoRepeat = disallowAutoRepeat
        self.dischargeAttributeId = dischargeAttributeId
        self.displayName = displayName
        self.durationAttributeId = durationAttributeId
        self.effectCategory = effectCategory
        self.effectId = effectId
        self.electronicChance = electronicChance
        self.falloffAttributeId = falloffAttributeId
        self.iconId = iconId
        self.isAssistance = isAssistance
        self.isOffensive = isOffensive
        self.isWarpSafe = isWarpSafe
        self.modifiers = modifiers
        self.name = name
        self.postExpression = postExpression
        self.preExpression = preExpression
        self.published = published
        self.rangeAttributeId = rangeAttributeId
        self.rangeChance = rangeChance
        self.trackingSpeedAttributeId = trackingSpeedAttributeId
    }

    public enum CodingKeys: String, CodingKey { 
        case _description = "description"
        case disallowAutoRepeat = "disallow_auto_repeat"
        case dischargeAttributeId = "discharge_attribute_id"
        case displayName = "display_name"
        case durationAttributeId = "duration_attribute_id"
        case effectCategory = "effect_category"
        case effectId = "effect_id"
        case electronicChance = "electronic_chance"
        case falloffAttributeId = "falloff_attribute_id"
        case iconId = "icon_id"
        case isAssistance = "is_assistance"
        case isOffensive = "is_offensive"
        case isWarpSafe = "is_warp_safe"
        case modifiers
        case name
        case postExpression = "post_expression"
        case preExpression = "pre_expression"
        case published
        case rangeAttributeId = "range_attribute_id"
        case rangeChance = "range_chance"
        case trackingSpeedAttributeId = "tracking_speed_attribute_id"
    }

}
