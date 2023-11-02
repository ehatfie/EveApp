//
//  ItemTypes.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/19/23.
//

import Foundation

class ItemType: Identifiable {
    var groupId: Int
    var typeId: Int
    var responseData: GetUniverseTypesTypeIdOk?
    
    convenience init(groupId: Int, typeId: Int) {
        self.init(
            groupId: groupId,
            typeId: typeId,
            itemTypeInfoResponseData: nil
        )
    }
    
    init(groupId: Int, typeId: Int, itemTypeInfoResponseData: GetUniverseTypesTypeIdOk?) {
        self.groupId = groupId
        self.typeId = typeId
        self.responseData = itemTypeInfoResponseData
    }
}
