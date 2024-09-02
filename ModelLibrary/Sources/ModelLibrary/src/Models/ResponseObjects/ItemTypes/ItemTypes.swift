//
//  ItemTypes.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/19/23.
//

import Foundation
import TestPackage3

public class ItemType: Identifiable {
    public var groupId: Int
    public var typeId: Int
    public var responseData: GetUniverseTypesTypeIdOk?
    
    public convenience init(groupId: Int, typeId: Int) {
        self.init(
            groupId: groupId,
            typeId: typeId,
            itemTypeInfoResponseData: nil
        )
    }
    
    public init(groupId: Int, typeId: Int, itemTypeInfoResponseData: GetUniverseTypesTypeIdOk?) {
        self.groupId = groupId
        self.typeId = typeId
        self.responseData = itemTypeInfoResponseData
    }
}
