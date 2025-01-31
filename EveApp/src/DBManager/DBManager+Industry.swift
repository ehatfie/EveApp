//
//  DBManager+Industry.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/14/23.
//

import Foundation
import Yams
import FluentKit
import ModelLibrary

extension DBManager {
  
  func loadIndustryData() async {
    do {
      try await loadTypeMaterialData()
      try await loadBlueprintData()
    } catch let error {
      print("loadIndustryData error \(error)")
    }
    
  }
  
  func loadTypeMaterialData() async throws {
    //print("loadTypeMaterialData() - Start")
    let start = Date()
    
    let typeMaterialsCount = try await self.database.query(TypeMaterialsModel.self).count().get()
    guard typeMaterialsCount == 0 else {
      return
    }
    
    let typeMaterials = try await readYamlAsync(for: .typeMaterials, type: TypeMaterialsData.self)
    let typeMaterialModels = typeMaterials.map { key, value in
      TypeMaterialsModel(typeID: key, materialData: value.materials)
    }
    
    try await splitAndSave(splits: 2, models: typeMaterialModels)

    //print("got \(typeMaterials.count)")
    print("loadTypeMaterialData() - End; Took - \(start.timeIntervalSinceNow * -1)")
  }
  
  func loadBlueprintData() async throws {
    //print("loadBlueprintData() - Start")
    
    guard try await self.database.query(BlueprintModel.self).count().get() == 0 else {
      return
    }
    
    let blueprintData = try await readYamlAsync(for: .blueprints, type: BlueprintData.self)
    
    let blueprintModels = blueprintData.map { key, value in
        return BlueprintModel(data: value)
    }
    
    let saveStart = Date()
    
    try await splitAndSave(splits: 2, models: blueprintModels)
    
    print("saved \(blueprintData.count) blueprints; took \(saveStart.timeIntervalSinceNow * -1)")
  }
}

// MARK: - Fetching Industry things

extension DBManager {
  func getInputObjects(for materialTypeId: Int64) async throws -> TypeModel? {
    try await TypeModel.query(on: self.database)
      .filter(\.$typeId == materialTypeId)
      .join(TypeMaterialsModel.self, on: \TypeMaterialsModel.$typeID == \TypeModel.$typeId)
      .first()
  }
}
