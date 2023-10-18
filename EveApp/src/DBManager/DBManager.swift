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
    
//    var categories: [CategoryModel] {
//      try! database.query(CategoryModel.self).all().wait()
//    }
//    
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
    
    init() {
      let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
      let threadPool = NIOThreadPool(numberOfThreads: 1)
      
      threadPool.start()
      
      databases = Databases(threadPool: threadPool, on: eventLoopGroup)
      
      //databases.use(.sqlite(.file(self.dbName)), as: .sqlite)
      databases.use(.sqlite(.memory), as: .sqlite)
      databases.default(to: .sqlite)
      
      setup()
      
        
      loadDogmaInfoData()
      
      
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
    
    func loadData() {
      print("loadData()")
      do {
        //try loadCategoryData()
        //try loadGroupData()
        //try loadTypeData()
        try loadDogmaData()
        
      } catch let error {
        print("Load data error \(error)")
      }
      
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
