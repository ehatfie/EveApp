//
//  BlueprintActivity.swift
//  ModelLibrary
//
//  Created by Erik Hatfield on 9/15/24.
//

import Foundation

/*
 1    Manufacturing
 3    Researching Time Efficiency
 4    Researching Material Efficiency
 5    Copying
 8    Invention
 11    Reactions
 */

public enum BlueprintActivity: Int {
    case manufacturing = 1
    case researchingTimeEfficiency = 3
    case researchingMaterialEfficiency = 4
    case copying = 5
    case invention = 8
    case reactions = 9
    
    public var description: String {
        switch self {
        case .manufacturing: return "Manufacturing"
        case .researchingTimeEfficiency: return "Researching Time Efficiency"
        case .researchingMaterialEfficiency: return "Researching Material Efficiency"
        case .copying: return "Copying"
        case .invention: return "Invention"
        case .reactions: return "Reactions"
        }
    }
}
