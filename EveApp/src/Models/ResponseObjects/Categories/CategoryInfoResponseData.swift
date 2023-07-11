//
//  CategoryInfoResponseData.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/3/23.
//

import Foundation

struct CategoryInfoResponseData: Codable {
    let category_id: Int32
    let groups: [Int32]
    let name: String
    let published: Bool
}
