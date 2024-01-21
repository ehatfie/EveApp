//
//  DBManager+query.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/7/23.
//

import Foundation
import Fluent
import FluentSQL

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
  
  func getGroup(for groupId: Int64) -> GroupModel? {
    return try! GroupModel.query(on: self.database)
      .filter(\.$groupId == groupId)
      .first()
      .wait()
  }
  
  func getCategories() -> [CategoryModel] {
    return try! CategoryModel.query(on: self.database)
      .all()
      .wait()
  }
  
  func getCategory(typeId: Int64) -> CategoryModel {
    let category = try! TypeModel.query(on: self.database)
      .filter(\.$typeId == typeId)
      .join(GroupModel.self, on: \GroupModel.$groupId == \TypeModel.$groupID)
      .join(CategoryModel.self, on: \CategoryModel.$categoryId == \GroupModel.$categoryID)
      .first()
      .wait()!.joined(CategoryModel.self)
    
    return category
  }
  
  func getCategory(groupId: Int64) -> CategoryModel {
    let categoryModel = try! GroupModel.query(on: self.database)
      .filter(\.$groupId == groupId)
      .join(CategoryModel.self, on: \CategoryModel.$categoryId == \GroupModel.$categoryID)
      .first().wait()!
      .joined(CategoryModel.self)
    return categoryModel
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
  
  func getRandomBlueprint() -> BlueprintModel? {
    let blueprints = try! BlueprintModel.query(on: self.database)
      .filter(\.$blueprintTypeID == 11394)
      .join(TypeModel.self, on: \TypeModel.$typeId == \BlueprintModel.$blueprintTypeID)
      .filter(TypeModel.self, \.$published == true)
      .filter(TypeModel.self, \.$metaGroupID == 2)
      .all()
      .wait()
    
    guard !blueprints.isEmpty else {
      return nil
    }
    
    let count = blueprints.count
    
    let rand = Int.random(in: 0..<count)
    
    return blueprints[rand]
  }
  
  func getType(for typeId: Int64) -> TypeModel {
    try! TypeModel.query(on: self.database)
      .filter(\.$typeId == typeId)
      .all()
      .wait()[0]
  }
  
  func getType1(for typeId: Int64) -> TypeModel {
    try! TypeModel.query(on: self.database)
      .field(\.$id).field(\.$typeId).field(\.$name)
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
  
  func getTypeAndMaterialModels(for typeId: Int64) -> TypeModel? {
    return try! TypeModel.query(on: self.database)
      .filter(\.$typeId == typeId)
      .join(TypeMaterialsModel.self, on: \TypeMaterialsModel.$typeID == \TypeModel.$typeId)
      .first()
      .wait()
  }
  
  func getTypeMaterialModels(for types: [Int64]) -> [TypeMaterialsModel] {
    try! TypeMaterialsModel.query(on: self.database)
      .filter(\.$typeID ~~ types)
      .all()
      .wait()
  }
  
  func getTests(for types: [Int64]) {
    let foo = try! TypeModel.query(on: self.database)
      .join(TypeMaterialsModel.self, on: \TypeModel.$typeId == \TypeMaterialsModel.$typeID)
      .filter(TypeModel.self, \.$typeId ~~ types)
      .all()
      .wait()
    
    foo.forEach { value in
      let materialsModel = try! value.joined(TypeMaterialsModel.self)
      print("got \(materialsModel.materialData.count) for \(value.name)")
    }
  }
  
  func getMaterialTypes(for type: Int64) -> [TypeModel] {
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
  
  func getMaterialTypes(for types: [Int64]) -> [TypeModel] {
    let results = try! TypeModel.query(on: self.database)
      .filter(\.$typeId ~~ types)
      .join(TypeMaterialsModel.self, on: \TypeModel.$typeId == \TypeMaterialsModel.$typeID)
      .all()
      .wait()
    return results
  }
  
  
}

// Mark: - Reactions

extension DBManager {
  func getReactionBlueprints() -> [TypeModel] {
    // all blueprints with a type id that matches a TypeModel that has a groupID that matches IndustryGroup.compositeReactionsFormula
    let foo = try! TypeModel.query(on: database)
      .filter(\.$groupID == IndustryGroup.compositeReactionsFormula.rawValue)
      .join(BlueprintModel.self, on: \BlueprintModel.$blueprintTypeID == \TypeModel.$typeId)
      .all()
      .wait()
    print("getReactionBlueprints got \(foo.count) things")
    return foo
  }
  
  func getBlueprint(for typeId: Int64) -> BlueprintModel? {
    let db = self.database
    guard let sql = db as? SQLDatabase else {
      return nil
    }
    let queryString =
      """
        select b.*, value from blueprintModel b,
        json_each(b.activities_manufacturing_products)
        where json_extract(value, '$.typeId') = \("\(typeId)")
      """
    
    return try? sql.raw(SQLQueryString(queryString))
      .first(decoding: BlueprintModel.self)
      .wait()
  }
  
  func getBlueprint1(for typeId: Int64) -> BlueprintModel? {
    let db = self.database
    guard let sql = db as? SQLDatabase else {
      return nil
    }
    let queryString =
      """
        select b.*, value from blueprintModel b,
        json_each(b.activities_reaction_products)
        where json_extract(value, '$.typeId') = \("\(typeId)")
      """
    
    return try? sql.raw(SQLQueryString(queryString))
      .first(decoding: BlueprintModel.self)
      .wait()
  }
}
