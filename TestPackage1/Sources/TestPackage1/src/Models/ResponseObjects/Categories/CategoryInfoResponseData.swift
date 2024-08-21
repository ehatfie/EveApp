//
//  CategoryInfoResponseData.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/3/23.
//

import Foundation

public struct CategoryInfoResponseData: Codable {
    public let category_id: Int32
    public let groups: [Int32]
    public let name: String
    public let published: Bool
    
    public init(category_id: Int32, groups: [Int32], name: String, published: Bool) {
        self.category_id = category_id
        self.groups = groups
        self.name = name
        self.published = published
    }
}
