//
//  ItemCategory.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/10/23.
//

import Foundation

class ItemCategory: Identifiable {
    var categoryId: Int32
    var categoryInfoResponseData: CategoryInfoResponseData?
    //var groupInfoResponseData: [GroupInfoResponseData]?

    
    convenience init(categoryId: Int32) {
        self.init(categoryId: categoryId, categoryInfoResponseData: nil)
    }
    
    init(categoryId: Int32, categoryInfoResponseData: CategoryInfoResponseData?) {
        self.categoryId = categoryId
        self.categoryInfoResponseData = categoryInfoResponseData
    }
    
}

// TODO: move

class ItemGroup: Identifiable {
    var categoryId: Int32?
    var groupId: Int32
    var groupInfoResponseData: GroupInfoResponseData?
    
    convenience init(categoryId: Int32? = nil, groupId: Int32) {
        self.init(
            categoryId: categoryId,
            groupId: groupId,
            groupInfoResponseData: nil
        )
    }
    
    init(
        categoryId: Int32?,
        groupId: Int32,
        groupInfoResponseData: GroupInfoResponseData?
    ) {
        self.categoryId = categoryId
        self.groupId = groupId
        self.groupInfoResponseData = groupInfoResponseData
    }
}

//class ItemTypes: Identifiable {
//    var capacity: Float?
//    var description: String
//    var dogma_attributes: [String]
//    var dogma_effects
//}
//
//
//class DogmaAttribute: Identifiable {
//    var effect_id: Int32
//    
//}
