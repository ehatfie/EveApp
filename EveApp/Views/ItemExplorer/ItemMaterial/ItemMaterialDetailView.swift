//
//  ItemMaterialDetailView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/20/23.
//

import SwiftUI
import Fluent
import TestPackage1

@MainActor
class ItemMaterialDetailViewModel: ObservableObject {
  @State var typeModel: TypeModel
  
  @Published var typeMaterialsModel: TypeMaterialsModel
  
  @Published var materials: [MaterialDataModel] = []
  @Published var materialTypes: [String] = []
  
  init(typeModel: TypeModel) {
    self.typeModel = typeModel
    
    let db = DataManager.shared.dbManager!.database
    
     typeMaterialsModel = try! TypeMaterialsModel.query(on: db)
      .filter(\.$typeID == typeModel.typeId)
      .first()
      .wait()! //?? [TypeMaterialsModel]()
    
    self.materials = typeMaterialsModel.materialData
    self.materialTypes = self.materials.compactMap { value in
      try! TypeModel.query(on: db)
        .filter(\.$typeId == value.materialTypeID)
        .first()
        .wait()?.name
    }
//    typeModel = foo!
//    
//    Task {
//      if let materials = try? await item.$materials
//        .get(on: db)
//        .get()
//      {
//        self.materials = materials
//        self.materialTypes = materials.compactMap { value in
//          try! TypeModel.query(on: db)
//            .filter(\.$typeId == value.materialTypeID)
//            .first()
//            .wait()
//        }
//      }
//    }
  }
  
  func getData() {
    //materials = item.materials
  }
}

struct ItemMaterialDetailView: View {
  @ObservedObject var viewModel: ItemMaterialDetailViewModel
  
  //    init() {
  //
  //    }
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("\(viewModel.typeModel.name)")
      VStack {
        HStack(alignment: .center) {
          ForEach($viewModel.materialTypes, id: \.string) { material in
            Text(material.wrappedValue)
            
            //Text("\(material.quantity)")
          }
          Spacer()
        }
        
        HStack(alignment: .center) {
          ForEach(viewModel.materials, id: \.materialTypeID) { material in
            Text("\(material.quantity)")
          }
          Spacer()
        }
      }
    }
  }
}

//#Preview {
//    ItemMaterialDetailView(item: TypeMaterialsModel(typeID: 0))
//}
