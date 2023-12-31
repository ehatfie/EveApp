//
// GetIndustrySystemsCostIndice.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** cost_indice object */

public struct GetIndustrySystemsCostIndice: Codable {

    public enum Activity: String, Codable { 
        case copying = "copying"
        case duplicating = "duplicating"
        case invention = "invention"
        case manufacturing = "manufacturing"
        case _none = "none"
        case reaction = "reaction"
        case researchingMaterialEfficiency = "researching_material_efficiency"
        case researchingTechnology = "researching_technology"
        case researchingTimeEfficiency = "researching_time_efficiency"
        case reverseEngineering = "reverse_engineering"
    }
    /** activity string */
    public var activity: Activity
    /** cost_index number */
    public var costIndex: Float

    public init(activity: Activity, costIndex: Float) {
        self.activity = activity
        self.costIndex = costIndex
    }

    public enum CodingKeys: String, CodingKey { 
        case activity
        case costIndex = "cost_index"
    }

}
