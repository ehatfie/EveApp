//
//  DBManager+loading.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Foundation
import Yams
import Fluent

extension DBManager {
  func loadDogmaData() async  {
    print("loadDogmaData()")
    do {
      // there is no protection against inserting the same values
      async let loadDogmaAttributes:Void =  loadDogmaAttributeData()
      async let loadDogmaEffects: Void =  loadDogmaEffectsData()
      async let loadDogmaAttributeCategories: Void = loadDogmaAttributeCategoryData()
      async let loadTypeDogmaInfo: Void =  loadTypeDogmaInfoDataAsync()
      
      _ = try await [
        loadDogmaAttributes,
        loadDogmaEffects,
        loadDogmaAttributeCategories,
        loadTypeDogmaInfo
      ]
    } catch let error {
      print("loadDogmaDataError \(error)")
    }
  }
  
  func loadDogmaInfoData() async {
    print("loadDogmaInfoData()")
    
    do {
    } catch let error {
      print("loadDogmaInfoError \(error)")
    }
  }
  
  func testCategoryData() throws {
    let categories = try readYaml(for: .categoryIDs, type: CategoryData.self)
    let groups = try readYaml(for: .groupIDs, type: GroupData.self)
    
    categories.forEach { key, value in
      let model = CategoryModel(id: key, data: value)
      
      
    }

    let groupModesl = groups.map { key, value in
      return GroupModel(groupId: key, groupData: value)
    }
  }
  
  
}

extension DBManager {
  func loadCategoryData() async throws {
    let categoryModelCount = try await self.database
      .query(CategoryModel.self)
      .count()
      .get()
    guard categoryModelCount == 0 else { return }
    print("loadCategoryData() - Start")
    let categoryIds = try loadCategoryID()
    try await categoryIds.create(on: database).get()
    print("loadCategoryData() - Done")
  }
  
  func loadGroupData() async throws {
    let groupModelCount = try await self.database
      .query(GroupModel.self)
      .count()
      .get()
    
    guard groupModelCount == 0 else { return }
    print("loadGroupData() - Start")
    let groupIds = try readYaml(for: .groupIDs, type: GroupData.self)
    
    let groupModels = groupIds.map { key, group in
      GroupModel(groupId: Int64(key), groupData: group)
    }
    
    try await groupModels.create(on: database)
    
    print("loadGroupData() - Done")
  }
  
  func loadTypeData() async throws {
    let typeModelCount = try await self.database
      .query(TypeModel.self)
      .count()
      .get()
    guard typeModelCount == 0 else { return }
    let start = Date()
    print("loadTypeData() - Start")
    let typeIds = try await readYamlAsync(for: .typeIDs, type: TypeData.self)
    print("loadTypeData() -  got \(typeIds.count) types")
    
    let typeModels = typeIds.map { key, type in
      return TypeModel(typeId: Int64(key), data: type)
    }
    print("loadTypeData() - created \(typeModels.count) type models")
    
    /*
    let keyValueCount = some.count
    
    let one = Array(some[0 ..< keyValueCount / 2])
    let two = Array(some[keyValueCount / 2 ..< keyValueCount])
    
    */
    try await splitAndSave(splits: 6, models: typeModels)

    print("loadTypeData() - Done, took: \(start.timeIntervalSinceNow)")
  }
  
  func loadDogmaAttributeData() async throws {
    let dogmaAttributeCount = try await self.database.query(DogmaAttributeModel.self).count().get()
    guard dogmaAttributeCount == 0 else {
      return
    }
    
    print("loadDogmaAttributeData() - Start")
    let dogmaAttributes = try await readYamlAsync(for: .dogmaAttrbutes, type: DogmaAttributeData.self)
    
    try await dogmaAttributes.map { key, value in
      DogmaAttributeModel(attributeId: key, data: value)
    }.create(on: database).get()

    print("loadDogmaAttributeData() - Done")
  }
  
  func loadDogmaEffectsData() async throws  {
    let dogmaEffectCount = try await self.database.query(DogmaEffectModel.self).count().get()
    
    guard dogmaEffectCount == 0 else { return }
    
    let dogmaEffects = try await readYamlAsync(for: .dogmaEffects, type: DogmaEffectData.self)
    
    try await dogmaEffects.map { key, value in
      DogmaEffectModel(dogmaEffectId: key, dogmaEffectData: value)
    }.create(on: database).get()
    
    print("loadDogmaEffectsData() - Done")
  }
  
  func loadDogmaAttributeCategoryData() async throws {
    let dogmaAttributeCategoryCount = try await self.database.query(DogmaAttributeCategoryModel.self).count().get()
    guard dogmaAttributeCategoryCount == 0 else { return }
    
    print("loadDogmaAttributeCategoryData() - Start")
    
    let dogmaAttributes = try readYaml(for: .dogmaAttributeCategories, type: TypeDogmaAttributeCategoryData.self)
    
    try await dogmaAttributes.map { key, value in
      DogmaAttributeCategoryModel(categoryId: key, data: value)
    }.create(on: database).get()
    
    print("loadDogmaAttributeCategoryData() - Done")
  }
  
  func loadCategoryID() throws -> [CategoryModel] {
    let categoryID = try readYaml(for: .categoryIDs, type: CategoryData.self)
    print("got \(categoryID.count) categories")
    return categoryID.map { key, value in
      return CategoryModel(id: key, data: value)
    }
    
  }
  
  func loadTypeDogmaInfoData() throws  {
    print("loadTypeDogmaInfoData()")
    
    let typeDogmaInfoCount = try self.database.query(TypeDogmaInfoModel.self).count().wait()
    guard typeDogmaInfoCount == 0 else { return }
    let start = Date()
    let info = try readYaml(for: .typeDogma, type: TypeDogmaData.self)
    print("Read info - \(start.timeIntervalSinceNow * -1)")
    
    //var attributeDict: [Int64: [TypeDogmaAttributeInfoModel]] = [:]
    //var effectDict: [Int64: [TypeDogmaEffectInfoModel]] = [:]
    
    try info.forEach { key, value in
      //Task {
      let result = TypeDogmaInfoModel(typeId: key, data: value)
      let attributes = value.dogmaAttributes.map {
        TypeDogmaAttributeInfoModel(
          typeID: key,
          attributeID: $0.attributeID,
          value: $0.value
        )
      }
      let effects = value.dogmaEffects.map {
        TypeDogmaEffectInfoModel(effectID: $0.effectID, isDefault: $0.isDefault)
      }
      
      try result.save(on: database).wait()
      
      ///}
    }
    
    //    try info.forEach { key, value in
    //      let result = TypeDogmaInfoModel(typeId: key)
    //      try result.create(on: database).wait()
    //
    //      let attributes = value.dogmaAttributes.map {
    //        TypeDogmaAttributeInfoModel(
    //          typeID: key,
    //          attributeID: $0.attributeID,
    //          value: $0.value
    //        )
    //      }
    //
    //      try result.$attributes
    //        .create(attributes, on: database)
    //        .wait()
    //
    //      let effects = value.dogmaEffects.map {
    //        TypeDogmaEffectInfoModel(effectID: $0.effectID, isDefault: $0.isDefault)
    //      }
    //
    //      try result.$effects
    //        .create(effects, on: database)
    //        .wait()
    //    }
    print("loadTypeDogmaInfoData done - \(start.timeIntervalSinceNow * -1)")
    print("")
  }
  
  func loadTypeDogmaInfoDataAsync() async throws  {
    print("loadTypeDogmaInfoDataAsync()")
    
    let typeDogmaInfoCount = try await self.database
      .query(TypeDogmaInfoModel.self)
      .count()
      .get()
    guard typeDogmaInfoCount == 0 else { return }
    let start = Date()
    
//    
//    // [String: Any]
//    let dictionary: [String: Any] = ["key": "value"]
//    let mapYAML: String = try Yams.dump(object: dictionary)
//    mapYAML == """
//    key: value
//
//    """
//    let loadedDictionary = try Yams.load(yaml: mapYAML) as? [String: Any]
//    
    
    let info = try await readYamlAsync(for: .typeDogma, type: TypeDogmaData.self)
    print("Read info - \(start.timeIntervalSinceNow * -1)")
    
    //var attributeDict: [Int64: [TypeDogmaAttributeInfoModel]] = [:]
    //var effectDict: [Int64: [TypeDogmaEffectInfoModel]] = [:]
    
    await saveDogmaInfoModel(data: info)

    return
    try info.forEach { key, value in
      //Task {
//      let result = TypeDogmaInfoModel(typeId: key)
//      let attributes = value.dogmaAttributes.map {
//        TypeDogmaAttributeInfoModel(
//          typeID: key,
//          attributeID: $0.attributeID,
//          value: $0.value
//        )
//      }
//      let effects = value.dogmaEffects.map {
//        TypeDogmaEffectInfoModel(effectID: $0.effectID, isDefault: $0.isDefault)
//      }
//      
//      try result.save(on: database)
//        .wait()
//      
//      try result.$effects.create(effects, on: database)
//        .wait()
//      try result.$attributes.create(attributes, on: database)
//        .wait()
      ///}
    }
    
    //    try info.forEach { key, value in
    //      let result = TypeDogmaInfoModel(typeId: key)
    //      try result.create(on: database).wait()
    //
    //      let attributes = value.dogmaAttributes.map {
    //        TypeDogmaAttributeInfoModel(
    //          typeID: key,
    //          attributeID: $0.attributeID,
    //          value: $0.value
    //        )
    //      }
    //
    //      try result.$attributes
    //        .create(attributes, on: database)
    //        .wait()
    //
    //      let effects = value.dogmaEffects.map {
    //        TypeDogmaEffectInfoModel(effectID: $0.effectID, isDefault: $0.isDefault)
    //      }
    //
    //      try result.$effects
    //        .create(effects, on: database)
    //        .wait()
    //    }
    print("loadTypeDogmaInfoDataAsync done - \(start.timeIntervalSinceNow * -1)")
    print("")
  }
  
  func saveDogmaInfoModel(data: [Int64: TypeDogmaData]) async {
    var index = 0
    print("saving \(data.count) dogma values")
    let foo = data.map { key, value in
      return TypeDogmaInfoModel(typeId: key, data: value)
    }
    
    try! await splitAndSave(splits: 4, models: foo)
    //try! await foo.create(on: database)
    
    
//    async let one = Task {
//      foo.forEach { value in
//        
//        guard let dogmaData = data[value.typeId] else { return }
//        let attributes = dogmaData.dogmaAttributes.map {
//          TypeDogmaAttributeInfoModel(
//            typeID: value.typeId,
//            attributeID: $0.attributeID,
//            value: $0.value
//          )
//        }
//        
//        try! value.$attributes.create(attributes, on: database).wait()
//      }
//    }
//    
//    async let two = Task {
//      foo.forEach { value in
//        guard let dogmaData = data[value.typeId] else { return }
//        
//        let effects = dogmaData.dogmaEffects.map {
//          TypeDogmaEffectInfoModel(effectID: $0.effectID, isDefault: $0.isDefault)
//        }
//        
//        try! value.$effects.create(effects, on: database).wait()
//      }
//    }
//    
//    let _ = await [one, two]
//    
//    data.forEach { key, value  in
//      
//      Task(priority: .userInitiated) {
//        try await saveTypeDogmaData(key: key, value: value)
//        print("finished \(key)")
//      }
//      
//
//    }
      
    
  }
  
  func saveTypeDogmaData(key: Int64, value: TypeDogmaData) async throws {
    let result = TypeDogmaInfoModel(typeId: key, data: value)
    let attributes = value.dogmaAttributes.map {
      TypeDogmaAttributeInfoModel(
        typeID: key,
        attributeID: $0.attributeID,
        value: $0.value
      )
    }
    //print("got \(attributes.count) attributes")
    let effects = value.dogmaEffects.map {
      TypeDogmaEffectInfoModel(effectID: $0.effectID, isDefault: $0.isDefault)
    }
    
    try await result.save(on: database)
      .get()
    //print("result saved")
//    async let createEffects: Void = result.$effects.create(effects, on: database).get()
//    //print("effect created")
//    async let createAttributes: Void = result.$attributes.create(attributes, on: database)
//      .get()
//      
//    
//    _ = try await [createEffects, createAttributes]
    //print("attributes created")
  }
  
//  func saveModel(models: [any Model]) async {
//    await models.create(on: database).get()
//  }
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
  func readYamlAsync<T: Decodable>(for fileName: YamlFiles, type: T.Type) async throws -> [Int64: T] {
    guard let path = Bundle.main.path(forResource: fileName.rawValue, ofType: "yaml") else {
      throw NSError(domain: "", code: 0)
    }
    
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    let yaml = String(data: data, encoding: .utf8)!
    let node = try Yams.compose(yaml: yaml)!
    
    return await decodeNode(node: node, type: T.self)
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
  
  func decodeNode<T: Decodable>(node: Yams.Node, type: T.Type) async -> [Int64: T] {
    guard let mapping = node.mapping else {
      print("NO MAPPING")
      return [:]
    }
    
    print("initial count \(mapping.count)")
    
    let keyValuePair = mapping.map { $0 }
    var returnValues: [Int64: T] = [:]
    
    
    print("Splitting")
    let splitStart = Date()
    let foo = await splitAndSort(splits: 5, some: keyValuePair, type: type)
    
    print("Split and sort done took \(splitStart.timeIntervalSinceNow * -1)")
    
    print("Merging")
    let mergeStart = Date()
    foo.forEach { value in
      returnValues.merge(value, uniquingKeysWith: { one, _ in one })
    }
    
    print("merge done took \(mergeStart.timeIntervalSinceNow * -1)")
    
    print("got others \(returnValues.count)")
    
    
    return returnValues
  }
  
  func splitAndSort<T: Decodable>(splits: Int, some: [Node.Mapping.Element], type: T.Type) async -> [[Int64: T]] {
    let keyValueCount = some.count
    
    let one = Array(some[0 ..< keyValueCount / 2])
    let two = Array(some[keyValueCount / 2 ..< keyValueCount])
    
    guard splits > 0 else {
      async let firstThing = sortThing(some: one, type: type)
      async let secondThing = sortThing(some: two, type: type)
      
      return await [firstThing, secondThing]
    }
    
    
    async let firstThing = splitAndSort(splits: splits - 1, some: one, type: type)
    async let secondThing = splitAndSort(splits: splits - 1, some: two, type: type)
    
    return await [firstThing, secondThing].flatMap { $0 }
  }
  
  func sortThing<T: Decodable>(some: [Node.Mapping.Element], type: T.Type) async -> [Int64: T] {
    var returnValue: [Int64: T] = [:]
    
    some.forEach { key, value in
      guard let keyValue = key.int else { return }
      do {
        let decrypted = try decodeValue(
          node: value,
          type: T.self
        )
        returnValue[Int64(keyValue)] = decrypted
      } catch let err {
        print("Decode error \(err)")
      }
    }
    
    return returnValue
  }
  
  func decodeValue<T: Decodable>(node: Node, type: T.Type) throws -> T {
    let decoder = YAMLDecoder()
    let result = try decoder.decode(T.self, from: node)
    return result
  }
  
  func splitAndSave<T: Model>(splits: Int, models: [T]) async throws {
    let modelCount = models.count
    
    let top = Array(models[0 ..< modelCount / 2])
    let bottom = Array(models[modelCount / 2 ..< modelCount])
    
    guard splits > 0 else {
      async let firstThing: Void = top.create(on: database).get()
      async let secondThing: Void = bottom.create(on: database).get()
      
      _ = try await [firstThing, secondThing]
      return
    }
    
    async let firstThing: Void = splitAndSave(splits: splits - 1, models: top)
    async let secondThing: Void = splitAndSave(splits: splits - 1, models: bottom)
    
    _ = try await [firstThing, secondThing]
  }

}
