//
//  BlueprintComponentView.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/1/23.
//

import SwiftUI
import Fluent

struct BlueprintComponentView: View {
  var blueprintModel: BlueprintModel
  
  let typeModels: [TypeModel]
  let typeMaterials: [TypeMaterialsModel]
  
  init(blueprintModel: BlueprintModel) {
    self.blueprintModel = blueprintModel
    
    let materials = blueprintModel.activities.manufacturing.materials
    let materialIds = materials.map { $0.typeId }
    
    let db = DataManager.shared.dbManager!.database
    
    let typeModels = materials.compactMap { value in
      try? TypeModel.query(on: DataManager.shared.dbManager!.database)
        .filter(\.$typeId == value.typeId)
        .first()
        .wait()
    }
    
    let typeMaterials = materials.compactMap { value in
      try? TypeMaterialsModel.query(on: DataManager.shared.dbManager!.database)
        .filter(\.$typeID == value.typeId)
        .first()
        .wait()
    }
    
    self.typeModels = typeModels
    self.typeMaterials = typeMaterials
    //blueprintModel.activities.manufacturing.
  }
  
  var body: some View {
    HStack {
      List(typeModels, id: \.typeId) { type in
        Text(type.name + "\(type.typeId)")
      }
      List(typeMaterials, id: \.typeID) { type in
        Text("\(type.typeID)")
      }
    }
    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
  }
}

#Preview {
  BlueprintComponentView(
    blueprintModel: BlueprintModel(
      data: BlueprintData(
        activities:
          BlueprintActivityData(
            copying: nil,
            manufacturing: nil,
            research_material: nil,
            research_time: nil
          ),
        blueprintTypeID: 0,
        maxProductionLimit: 0))
  )
}
