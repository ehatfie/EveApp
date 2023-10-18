//
//  DBManager+Mocks.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/17/23.
//

import Foundation
import FluentKit

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
    
    let ourData = data as! GroupData
    
  }
}



class ModelGenerator {
  let numCategories = 10
  let numGroups = 20
  
  
  func generateModels() -> [CategoryModel] {
    print("GenerateModels() - generating \(numCategories) models")
    var generatedModels = [CategoryModel]()
    
    for i in 0...numCategories {
      let categoryData = CategoryData(name: ThingName(name: "Category \(i)"), published: true)
      let categoryModel = CategoryModel(id: Int64(i), data: categoryData)
      
      generatedModels.append(categoryModel)
    }
    
    generateModel(count: 10, type: SomeModel.self, data: MockData.self)
    
    return generatedModels
  }
  
  func generateModel<T:SomeProtocol>(count: Int, type: T.Type, data: MockableData.Type) -> [any SomeProtocol] {
    var returnData = [any SomeProtocol]()
    
    for i in 0...count {
      let model = type.init(id: Int64(i), data: data.init(id: Int64(i)))
      returnData.append(model)
    }
    
    let foo = T(id: 0, data: data.init(id: 0))
    return returnData
  }
  
  func generateGroups(count: Int) -> [GroupModel] {
    
    return []
  }
  
}


