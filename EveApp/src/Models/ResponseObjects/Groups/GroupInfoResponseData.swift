//
//  GroupInfoResponseData.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/10/23.
//

import Foundation


struct GroupInfoResponseData: Codable {
    let category_id: Int32?
    let group_id: Int32
    let name: String
    let published: Bool
    let types: [Int32]
}
