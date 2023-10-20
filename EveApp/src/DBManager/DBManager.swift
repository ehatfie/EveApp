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
  let databases: Databases
  let dbName = "TestDB4"
  
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
  
  @Published var dbLoaded: Bool = false
  
  init() {
    let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    let threadPool = NIOThreadPool(numberOfThreads: 1)
    
    threadPool.start()
    
    databases = Databases(threadPool: threadPool, on: eventLoopGroup)
    
    //databases.use(.sqlite(.file(self.dbName)), as: .sqlite)
    databases.use(.sqlite(.memory), as: .sqlite)
    databases.default(to: .sqlite)
    
    setup()
    
    Task {
      await loadMockedData()
    }
    
    
    //loadDogmaInfoData()
    
    
    //try? testCategoryData()
    //try? loadIndustryData()
  }
  
  func setup() {
    do {
      try categoryDataStuff()
      try setupDogmaEffectModel()
      
    } catch let error {
      print("AppModel error setup \(error)")
    }
    try? setupDogmaAttributeModel()
    try? setupDogmaAttributeCategoryModel()
    
    try? groupDataStuff()
    try? setupTypeData()
    
    try? setupTypeDogmaEffectInfoModel()
    try? setupTypeDogmaAttributeInfoModel()
    try? setupTypeDogmaInfoModel()
    
    try? setupTypeMaterialModels()
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
  
  func loadData() {
    print("loadData()")
    do {
      //try loadCategoryData()
      //try loadGroupData()
      //try loadTypeData()
      loadDogmaData()
      
    } catch let error {
      print("Load data error \(error)")
    }
    
  }
  
  func save(_ model: any Model) async throws {
    //try model.save(on: database).get()
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
    try CreateTypeDogmaInfoModel()
      .prepare(on: database)
      .wait()
  }
  
  func setupTypeMaterialModels() throws {
    try TypeMaterialsModel.ModelMigration()
      .prepare(on: database)
      .wait()
    
    try MaterialDataModel.CreateMaterialDataModelMigration()
      .prepare(on: database)
      .wait()
  }
}
