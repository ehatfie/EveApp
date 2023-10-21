//
//  DBManager+Industry.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/14/23.
//

import Foundation
import Yams

extension DBManager {
  
  func loadIndustryData() async {
    do {
      try await loadTypeMaterialData()
    } catch let error {
      print("loadIndustryData error \(error)")
    }
    
  }
  
  func loadTypeMaterialData() async throws {
    print("loadTypeMaterialData() - Start")
    let start = Date()
    
    let typeMaterialsCount = try await self.database.query(TypeMaterialsModel.self).count().get()
    guard typeMaterialsCount == 0 else {
      return
    }
    
    let typeMaterials = try await readYamlAsync(for: .typeMaterials, type: TypeMaterialsData.self)
    
    try typeMaterials.forEach { key, value in
      let typeMaterialModel = TypeMaterialsModel(typeID: key)
      
      try typeMaterialModel.save(on: database).wait()
      
      let materialModels = value.materials.map { value in
          MaterialDataModel(data: value)
      }
      
      try typeMaterialModel.$materials.create(materialModels, on: database).wait()
    }
    print("got \(typeMaterials.count)")
    
    print("loadTypeMaterialData() - End; Took - \(start.timeIntervalSinceNow * -1)")
  }
}
