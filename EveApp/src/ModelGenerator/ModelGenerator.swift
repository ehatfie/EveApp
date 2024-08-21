//
//  ModelGenerator.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/17/23.
//

import Foundation
import FluentKit
import TestPackage1

protocol SomeProtocol: Model {
  init(id: Int64, data: Codable)
}

protocol MockableData: Codable {
  init(id: Int64)
}

struct MockData: MockableData {
  init(id: Int64) {
    
  }
}

class SomeModel: SomeProtocol {
  
  static let schema = Schemas.groups.rawValue
  @ID(key: .id) var id: UUID?
  
  var someID: Int64 = 0
  
  required init() { }
  
  required init(id: Int64, data: Codable) {
    someID = id
    
    //let ourData = data as! GroupData
    
  }
}

class ModelGenerator {
  let numCategories = 20
  let numGroups = 50
  let numTypes = 30000
  
  let groupsPerCategory = 10
  let typesPerGroup = 1000
  
  
  func generateCategoryModels() -> [CategoryModel] {
    print("GenerateModels() - generating \(numCategories) models")
    var generatedModels = [CategoryModel]()
    
    for i in 0...numCategories {
      let categoryData = CategoryData(name: ThingName(name: "Category \(i)"), published: true)
      let categoryModel = CategoryModel(id: Int64(i), data: categoryData)
      generatedModels.append(categoryModel)
    }
    
    //generateModel(count: 10, type: SomeModel.self, data: MockData.self)
    
    return generatedModels
  }
    
  func generateGroupModels() -> [GroupModel] {
    print("GenerateGroupModels() - generating \(numGroups) models")
    var generatedModels = [GroupModel]()
    var currentCategory: Int64 = 0
    
    
    for i in 0...numGroups {
      let groupData = GroupData(id: currentCategory, name: "Group \(i)")
      let groupModel = GroupModel(groupId: Int64(i), groupData: groupData)
      generatedModels.append(groupModel)
      
      if i % groupsPerCategory == 0 && currentCategory < numCategories {
        currentCategory += 1
      }
    }
    
    return generatedModels
  }
  
  func generateTypeModels() -> [TypeModel] {
    print("GenerateTypeModels() - generating \(numTypes) models")
    var generatedModels = [TypeModel]()
    var currentGroup: Int64 = 0
    
    for i in 0...numTypes {
      let typeData = TypeData(groupID: currentGroup, name: ThingName(name: "Type \(i)"), portionSize: 0, published: true)
      let typeModel = TypeModel(typeId: 0, data: typeData)
      generatedModels.append(typeModel)
      
      if i % typesPerGroup == 0 && currentGroup < numGroups {
        currentGroup += 1
      }
    }
    //let typeData = TypeData(groupID: 0, portionSize: 0, published: true)
    
    return generatedModels
  }
  
  func generateModel<T:SomeProtocol>(count: Int, type: T.Type, data: MockableData.Type) -> [any SomeProtocol] {
    var returnData = [any SomeProtocol]()
    
    for i in 0...count {
      let model = type.init(id: Int64(i), data: data.init(id: Int64(i)))
      returnData.append(model)
    }
    
   // let foo = T(id: 0, data: data.init(id: 0))
    return returnData
  }
  
  func generateGroups(count: Int) -> [GroupModel] {
    
    return []
  }
  
}
