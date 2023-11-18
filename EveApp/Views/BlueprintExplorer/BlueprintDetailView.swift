//
//  BlueprintDetailView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/26/23.
//

import SwiftUI
import Fluent

struct BlueprintDetailView: View {
  var blueprint: BlueprintModel
  var typeModel: TypeModel?
  
  init(blueprint: BlueprintModel) {
    let db = DataManager.shared.dbManager!.database
    
    self.blueprint = blueprint
    
    let foo = try! TypeModel.query(on: db)
      .filter(\.$typeId == blueprint.blueprintTypeID)
      .first()
      .wait()
    self.typeModel = foo
    
  }
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        if let typeModel = self.typeModel {
          Text("\(typeModel.name)")
            .font(.title)
          Text("\(typeModel.groupID)")
        }
      }
      
      HStack {
        activitiesView(for: blueprint.activities)
        componentsView(for: blueprint.activities.manufacturing)
      }
      
    }
  }
  
  func format(seconds: Int) -> String {
    String(format:"%d:%02d", seconds / 60, seconds % 60)
  }
  
  func activitiesView(for model: BlueprintActivityModel) -> some View {
    
    let copyTime = Duration(
      secondsComponent: 60,
      attosecondsComponent: 0
    )
    
    let manufacturingTime = Duration(
      secondsComponent: model.manufacturing.time / 1,
      attosecondsComponent: 0
    )
    
    return VStack(alignment: .leading) {
      manufacturingView(for: model.manufacturing)
      HStack {
        Text("copying time: ")
        Text(copyTime.formatted())
      }
      
      HStack {
        Text("Manufacturing Time:")
        Text(manufacturingTime.formatted())
      }
      
    }
  }
  
  func manufacturingView(for model: BlueprintManufacturingModel) -> some View {
    return VStack(alignment: .leading, spacing: 15) {
      MaterialDetailView(
        title: "Materials",
        materials: model.materials
      )
      MaterialDetailView(
        title: "Products",
        materials: model.products
      )
    }//.border(.red)
  }
  
  func componentsView(for model: BlueprintManufacturingModel) -> some View {
    let typeIds = model.materials.map { $0.typeId }
    let types = DataManager.shared.dbManager!.getTypes(for: typeIds)
    
    
    return VStack(){
      Text("Components View")
      List(types, id: \.id) { material in
        Text(material.name)
        typeMaterialView(for: material)
      }
      Spacer()
      
    }
  }
  
  func typeMaterialView(for type: TypeModel) -> some View {
    if let materialTypes = DataManager.shared.dbManager!
      .getTypeMaterialModel(for: type.typeId) {
      
      return VStack {
        Text("gottem")
//        ForEach(materialTypes, id: \.id) { material in
//          Text(material.name)
//        }
      }
    }
    
    return VStack {
      Text("NO materials")
    }
  }
}

//#Preview {
//    BlueprintDetailView()
//}
