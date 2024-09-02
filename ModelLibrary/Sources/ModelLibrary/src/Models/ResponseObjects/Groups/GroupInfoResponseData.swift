//
//  GroupInfoResponseData.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/10/23.
//

import Foundation


public struct GroupInfoResponseData: Codable {
    public let category_id: Int32?
    public let group_id: Int32
    public let name: String
    public let published: Bool
    public let types: [Int32]
    
    public init(category_id: Int32?, group_id: Int32, name: String, published: Bool, types: [Int32]) {
        self.category_id = category_id
        self.group_id = group_id
        self.name = name
        self.published = published
        self.types = types
    }
}
