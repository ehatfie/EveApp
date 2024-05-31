//
//  DBManager.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Foundation
import SwiftUI

import NIO
import Fluent

class DBManager: ObservableObject {
  var databases: Databases
  let dbName = "TestDB27"
  
  let numThreads = 6
  
  var logger: Logger = {
    var logger = Logger(label: "database.logger")
    logger.logLevel = .info
    return logger
  }()
  
  var database: Database {
    return self.databases.database(
      logger: logger,
      on: self.databases.eventLoopGroup.next()
    )!
  }
  
  @Published var dbLoading: Bool = false
  @Published var dbLoaded: Bool = false
  
  
  init() {
      let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: self.numThreads)
      let threadPool = NIOThreadPool(numberOfThreads: self.numThreads)
      
      //DispatchQueue.main.async {
        threadPool.start()
      //}
    
      self.databases = Databases(threadPool: threadPool, on: eventLoopGroup)

      databases.use(.sqlite(.file(self.dbName)), as: .sqlite)
      //databases.use(.sqlite(.memory), as: .sqlite)
      databases.default(to: .sqlite)
    

    
    setup()
//    Task {
//      try? await setupModelsAsync()
//    }
    loadStaticData()
  }
  
  func log(_ text: String) {
    print("DBManager - \(text)")
  }
  
  func setup() {
    do {

      try setupCharacterDataModels()
      
    } catch let error {
      print("AppModel error setup \(error)")
    }
    
    try? setupAuthModels()
    try? categoryDataStuff()
    try? setupDogmaEffectModel()
    try? setupDogmaAttributeModel()
    try? setupDogmaAttributeCategoryModel()
    
    try? groupDataStuff()
    try? setupTypeData()
    
    try? setupTypeDogmaEffectInfoModel()
    try? setupTypeDogmaAttributeInfoModel()
    try? setupTypeDogmaInfoModel()
    
    try? setupTypeMaterialModels()
    
    try? setupBlueprintModel()
    
//    Task {
//      try? await CharacterAssetsDataModel
//        .ModelMigration()
//        .prepare(on: database)
//        .get()
//    }


  }
  
  func loadMockedData() async  {
    print("loadMockedData()")
    let modelGenerator = ModelGenerator()
    
    let categoryModels = modelGenerator.generateCategoryModels()
    let groupModels = modelGenerator.generateGroupModels()
    let typeModels = modelGenerator.generateTypeModels()
    
    do {
      async let createCategories: Void = try categoryModels.create(on: database).get()
      async let createGroups: Void = try groupModels.create(on: database).get()
      async let createTypes: Void = try typeModels.create(on: database).get()
      
     _ = try await [createCategories, createGroups, createTypes]
      self.dbLoaded = true
      print("loadMockedData - async finish")
    } catch let error {
      print("loadMockedData - error: \(error)")
    }
  }
  
  func loadStaticData() {
    Task {
      
      //async let loadIndustryData: Void = loadIndustryData()
      
      //await loadData
      //await loadIndustryData
      
      //DispatchQueue.main.async {
      self.dbLoading = true
      //}
      await loadData()
      await loadIndustryData()
      
      DispatchQueue.main.async {
        self.dbLoading = false
      }
    }
  }
  
  func loadData() async {
    print("loadData()")
    
    
    let start = Date()
    do {
      _ = try await [
        loadCategoryData(),
        loadGroupData()
      ]
      
      try await loadTypeData()
      await loadDogmaData()
      try await loadMiscDataAsync()
      print("Load data took \(start.timeIntervalSinceNow * -1)")
    } catch let error {
      self.dbLoading = false
      print("Load data error \(error)")
    }
  }
  
  func save(_ model: any Model) async throws {
    try await model.save(on: database).get()
  }
  
  func categoryDataStuff() throws {
    try CreateCategoryModelMigration()
      .prepare(on: database)
      .wait()
  }
  
  func groupDataStuff() throws {
    try CreateGroupModelMigration()
      .prepare(on: database)
      .wait()
  }
  
  func setupTypeData() throws {
    try CreateTypeModelMigration()
      .prepare(on: database)
      .wait()
  }
  
  func setupDogmaAttributeModel() throws {
    try CreateDogmaAttributeModelMigration()
      .prepare(on: database)
      .wait()
  }
  
  func setupDogmaAttributeCategoryModel() throws {
    try CreateDogmaAttributeCategoryModelMigration()
      .prepare(on: database)
      .wait()
  }
  
  func setupDogmaEffectModel() throws {
    try CreateDogmaEffectModelMigration()
      .prepare(on: database)
      .wait()
  }
  
  func setupTypeDogmaEffectInfoModel() throws {
    try CreateTypeDogmaEffectInfoModel()
      .prepare(on: database)
      .wait()
  }
  
  func setupTypeDogmaAttributeInfoModel() throws {
    try CreateTypeDogmaAttributeInfoModel()
      .prepare(on: database)
      .wait()
  }
  
  func setupTypeDogmaInfoModel() throws {
    try TypeDogmaInfoModel.CreateTypeDogmaInfoModel()
      .prepare(on: database)
      .wait()
  }
  
  func setupTypeMaterialModels() throws {
    try TypeMaterialsModel.ModelMigration()
      .prepare(on: database)
      .wait()
    
//    try MaterialDataModel.CreateMaterialDataModelMigration()
//      .prepare(on: database)
//      .wait()
  }
  
  func setupBlueprintModel() throws {
    try BlueprintModel.ModelMigration()
      .prepare(on: database)
      .wait()
  }
  
  func setupCharacterDataModels() throws {
    try CharacterDataModel.ModelMigration()
      .prepare(on: database)
      .wait()
    
    try CharacterPublicDataModel.ModelMigration()
      .prepare(on: database)
      .wait()
    
    try CharacterAssetsDataModel.ModelMigration()
      .prepare(on: database)
      .wait()
    
  }
  
  func setupAuthModels() throws {
    try AuthModel.ModelMigration()
      .prepare(on: database)
      .wait()
  }

}


// MARK: - Async model migrations
extension DBManager {
  func setupModelsAsync() async throws {
    let _ = try await [
      setupBlueprintModelAsync(),
      setupMiscModelsAsync()
    ]
  }
  
  func setupBlueprintModelAsync() async throws {
    try await BlueprintModel.ModelMigration()
      .prepare(on: database)
      .get()
  }
  
  func setupMiscModelsAsync() async throws {
    try await RaceModel.ModelMigration()
      .prepare(on: database)
      .get()
  }
  
}


extension DBManager {

  func deleteAll() async {
    print("deleteAll() - start")
    do {
      let _ = [
        try await deleteType(GroupModel.self),
        try await deleteType(CategoryModel.self),
        try await deleteType(TypeModel.self),
        try await deleteType(DogmaEffectModel.self),
        try await deleteType(DogmaAttributeModel.self),
        try await deleteType(DogmaAttributeCategoryModel.self),
        try await deleteType(TypeDogmaInfoModel.self),
        try await deleteType(TypeMaterialsModel.self)
      ]
    } catch let error {
      print("delete error \(error)")
    }
    
    print("deleteAll() - done")
  }
  
  func deleteTypes(_ types: [any Model.Type]) async throws {
    
    await withTaskGroup(of: Void.self) { taskGroup in
      for type in types {
        taskGroup.addTask { try! await self.deleteType(type) }
      }
      
      await taskGroup.waitForAll()
    }
  }
  
  func deleteTypes(_ types: [any Model.Type]){
    print("deleting \(types.count) types")
    
    Task {
      do {
        try await deleteTypes(types)
      } catch let error {
        print("delte types error \(error)")
      }
    }
  }
  
  func deleteType<T: Model>(_ type: T.Type) async throws {
    try await T.query(on: self.database)
      .all()
      .get()
      .delete(on: self.database)
  }
  
  func deleteType<T: Model>(_ type: T.Type) async throws -> T.Type {
    try await T.query(on: self.database)
      .all()
      .get()
      .delete(on: self.database)
    return T.self
  }
  
}
