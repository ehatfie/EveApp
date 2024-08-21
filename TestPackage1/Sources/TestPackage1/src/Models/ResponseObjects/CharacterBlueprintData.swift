//
//  CharacterBlueprintData.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/3/23.
//

import Foundation

struct CharacterBlueprintData: Codable {
    let item_id: Int64
    let location_flag: String
    let location_id: Int64
    let material_efficiency: Int32
    let quantity: Int32
    let runs: Int32
    let time_efficiency: Int32
    let type_id: Int32
}
