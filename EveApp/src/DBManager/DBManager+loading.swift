//
//  DBManager+loading.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Foundation
import Yams

extension DBManager {
  func loadDogmaData() {
    print("loadDogmaData()")
    do {
      try loadDogmaAttributeData()
      try loadDogmaEffectsData()
      try loadDogmaAttributeCategoryData()
    } catch let error {
      print("loadDogmaDataError \(error)")
    }
  }
}

extension DBManager {
  func loadCategoryData() throws {
    let categoryModelCount = try self.database.query(CategoryModel.self).count().wait()
    guard categoryModelCount == 0 else { return }
    print("loadCategoryData() - Start")
    let categoryIds = try loadCategoryID()
    try categoryIds.forEach { category in
      try category.save(on: database).wait()
    }
    print("loadCategoryData() - Done")
  }
  
  func loadGroupData() throws {
    let groupModelCount = try self.database.query(GroupModel.self).count().wait()
    guard groupModelCount == 0 else { return }
    print("loadGroupData() - Start")
    let groupIds = try readYaml(for: .groupIDs, type: GroupData.self)
    
    try groupIds.forEach { key, group in
      let group = GroupModel(groupId: Int64(key), groupData: group)
      try group.save(on: database).wait()
    }
    print("loadGroupData() - Done")
  }
  
  func loadTypeData() throws {
    let typeModelCount = try self.database.query(TypeModel.self).count().wait()
    guard typeModelCount == 0 else { return }
    let start = Date()
    print("loadTypeData() - Start")
    let typeIds = try readYaml(for: .typeIDs, type: TypeData.self)
    print("loadTypeData() -  got \(typeIds.count) types")
    
    try typeIds.forEach { key, type in
      let type = TypeModel(typeId: Int64(key), data: type)
      try type.save(on: database).wait()
    }
    
    print("loadTypeData() - Done, took: \(start.timeIntervalSinceNow)")
  }
  
  func loadDogmaAttributeData() throws {
    let dogmaAttributeCount = try self.database.query(DogmaAttributeModel.self).count().wait()
    guard dogmaAttributeCount == 0 else {
      return
    }
    
    print("loadDogmaAttributeData() - Start")
    
    let dogmaAttributes = try readYaml(for: .dogmaAttrbutes, type: DogmaAttributeData.self)
    
    try dogmaAttributes.forEach { key, value in
      let dogma = DogmaAttributeModel(attributeId: key, data: value)
      try dogma.save(on: database).wait()
    }
    print("loadDogmaAttributeData() - Done")
  }
  
  func loadDogmaEffectsData() throws  {
    let dogmaEffectCount = try self.database.query(DogmaEffectModel.self).count().wait()
    
    guard dogmaEffectCount == 0 else { return }
    
    let dogmaEffects = try readYaml(for: .dogmaEffects, type: DogmaEffectData.self)
    
    try dogmaEffects.forEach { key, value in
      let dogmaEffect = DogmaEffectModel(dogmaEffectId: key, dogmaEffectData: value)
      try dogmaEffect.save(on: database).wait()
    }
    print("loadDogmaEffectsData() - Done")
  }
  
  func loadDogmaAttributeCategoryData() throws {
    let dogmaAttributeCategoryCount = try self.database.query(DogmaAttributeCategoryModel.self).count().wait()
    guard dogmaAttributeCategoryCount == 0 else { return }
    
    print("loadDogmaAttributeCategoryData() - Start")
    
    let dogmaAttributes = try readYaml(for: .dogmaAttributeCategories, type: TypeDogmaAttributeCategoryData.self)
    
    try dogmaAttributes.forEach { key, value in
      let dogma = DogmaAttributeCategoryModel(categoryId: key, data: value)
      try dogma.save(on: database).wait()
    }
    
    print("loadDogmaAttributeCategoryData() - Done")
  }
  
  func loadCategoryID() throws -> [CategoryModel] {
    let categoryID = try readYaml(for: .categoryIDs, type: CategoryData.self)
    print("got \(categoryID.count) categories")
    return categoryID.map { key, value in
      return CategoryModel(id: key, data: value)
    }
    
  }
}

// MARK: - Yaml stuff

extension DBManager {
  func readYaml<T: Decodable>(for fileName: YamlFiles, type: T.Type) throws -> [Int64: T] {
    guard let path = Bundle.main.path(forResource: fileName.rawValue, ofType: "yaml") else {
      throw NSError(domain: "", code: 0)
    }
    
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    let yaml = String(data: data, encoding: .utf8)!
    let node = try Yams.compose(yaml: yaml)!
    
    return decodeNode(node: node, type: T.self)
  }
  
  func decodeNode<T: Decodable>(node: Yams.Node, type: T.Type) -> [Int64: T] {
    guard let mapping = node.mapping else {
      print("NO MAPPING")
      return [:]
    }
    
    print("initial count \(mapping.count)")
    
    let keyValuePair = mapping.map { $0 }
    var returnValues: [Int64: T] = [:]
    print("got keyvalue pairs \(keyValuePair.count)")
    
    keyValuePair.forEach { key, value in
      guard let keyValue = key.int else { return }
      do {
        let decrypted = try decodeValue(
          node: value,
          type: T.self
        )
        returnValues[Int64(keyValue)] = decrypted
      } catch let err {
        print("Decode error \(err)")
      }
    }
    
    print("got others \(returnValues.count)")
    
    
    return returnValues
  }
  
  func decodeValue<T: Decodable>(node: Node, type: T.Type) throws -> T {
    let decoder = YAMLDecoder()
    let result = try decoder.decode(T.self, from: node)
    return result
  }
}
