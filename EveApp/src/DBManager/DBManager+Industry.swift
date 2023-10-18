//
//  DBManager+Industry.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/14/23.
//

import Foundation
import Yams

extension DBManager {
  
  func loadIndustryData() {
    do {
      try loadTypeMaterialData()
    } catch let error {
      print("loadIndustryData error \(error)")
    }
    
  }
  
  func loadTypeMaterialData() throws {
    print("loadTypeMaterialData() - Start")
    let typeMaterials = try readYaml(for: .typeMaterials, type: TypeMaterialsData.self)
    
    print("got \(typeMaterials.count)")
    
    print("loadTypeMaterialData() - End")
  }
}
