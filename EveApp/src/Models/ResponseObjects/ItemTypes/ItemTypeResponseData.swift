//
//  ItemType.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/10/23.
//

import Foundation


struct ItemTypeResponseData: Codable {
    let capactiy: Float?
    let description: String
    let dogma_attributes: [DogmaAttributeData]
    let dogma_effects: [DogmaEffect]
    let graphic_id: Int32?
    let group_id: Int32
    let icon_id: Int32?
    let market_group_id: Int32?
    let mass: Float?
    let name: String
    let packaged_volume: Float?
    let portion_size: Int32?
    let published: Bool
    let radius: Float
}

struct DogmaAttributeData: Codable {
    let attribute_id: Int32
    let value: Float
}

struct DogmaEffect: Codable {
    let effect_id: Int32
    let is_default: Bool
}
