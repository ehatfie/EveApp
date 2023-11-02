//
//  ItemMaterialDetailView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/20/23.
//

import SwiftUI
import Fluent

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
      .with(\.$materials)
      .first()
      .wait()!
    self.materials = typeMaterialsModel.materials
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
    VStack {
      Text("\(viewModel.typeModel.name)")
      HStack {
        
        VStack(alignment: .trailing) {

          ForEach($viewModel.materialTypes, id: \.string) { material in
            Text(material.wrappedValue)
            
            //Text("\(material.quantity)")
          }
        }
        
        VStack(alignment: .leading) {
          ForEach(viewModel.materials, id: \.id) { material in
            Text("\(material.quantity)")
          }
        } 
      }
    }
  }
}

//#Preview {
//    ItemMaterialDetailView(item: TypeMaterialsModel(typeID: 0))
//}
