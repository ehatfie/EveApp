//
//  DBManager+query.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/7/23.
//

import Foundation
import Fluent

struct TypeNamesResult {
  let typeId: Int64
  let name: String
}

extension DBManager {
  func getGroups() -> [GroupModel] {
    return try! GroupModel.query(on: self.database)
      .all()
      .wait()
  }
  
  func getGroups(in categoryId: Int64) -> [GroupModel] {
    return try! GroupModel.query(on: self.database)
      .filter(\.$categoryID == categoryId)
      .all()
      .wait()
  }
  
  func getCategories() -> [CategoryModel] {
    return try! CategoryModel.query(on: self.database)
      .all()
      .wait()
  }
}

extension DBManager {
  func getTypeNames(for typeIds: [Int64]) -> [TypeNamesResult] {
    let results = try! TypeModel.query(on: self.database)
      .filter(\.$typeId ~~ typeIds)
      .all()
      .wait()
      .map({ TypeNamesResult(typeId: $0.typeId, name: $0.name) })
    return results
  }
  
  func getObjects<T: Model>(for type: T.Type, filter: ModelFieldFilter<T, T>) -> [T] {
    try! T.query(on: self.database)
      .filter(filter)
      .all()
      .wait()
  }
  
  func getRandomBlueprint() -> BlueprintModel {
    let blueprints = try! BlueprintModel.query(on: self.database)
      .join(TypeModel.self, on: \TypeModel.$typeId == \BlueprintModel.$blueprintTypeID)
      .filter(TypeModel.self, \.$published == true)
      .all()
      .wait()
    
    let count = blueprints.count
    let rand = Int.random(in: 0...count)
    
    return blueprints[rand]
  }
  
  func getType(for typeId: Int64) -> TypeModel {
    try! TypeModel.query(on: self.database)
      .filter(\.$typeId == typeId)
      .all()
      .wait()[0]
  }
  
  func getTypes(for typeIds: [Int64]) -> [TypeModel] {
    try! TypeModel.query(on: self.database)
      .filter(\.$typeId ~~ typeIds)
      .all()
      .wait()
  }
  
  func getTypeMaterialModel(for type: Int64) -> TypeMaterialsModel? {
    return try! TypeMaterialsModel.query(on: self.database)
      .filter(\.$typeID == type)
      .first()
      .wait()
  }
  
  func getMaterialTypes(for type: Int64) -> [TypeModel] {
    /*
     .join(TypeMaterialsModel.self, on: \TypeModel.$typeId == \TypeMaterialsModel.$typeID)
     .first().wait()
     */
//    let typeMaterials = try! TypeMaterialsModel.query(on: self.database)
//      .filter(\.$typeID == type)
//      .first()
//      .wait()
//    
//    if let blueprint = typeMaterials {
//      
//    }
    
    let results = try! TypeModel.query(on: self.database)
      .filter(\.$typeId == type)
      .join(TypeMaterialsModel.self, on: \TypeModel.$typeId == \TypeMaterialsModel.$typeID)
      .all()
      .wait()
    
    if results.count > 0 {
      let foo = try! results[0].joined(TypeMaterialsModel.self)
      print("got foo \(foo)")
    }
    
    return results
  }
}
