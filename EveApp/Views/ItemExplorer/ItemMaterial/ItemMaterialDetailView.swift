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
  @State var item: TypeMaterialsModel
  @State var typeModel: TypeModel
  @Published var materials: [MaterialDataModel] = []
  @Published var materialTypes: [TypeModel] = []
  
  init(item: TypeMaterialsModel) {
    self.item = item
    let db = DataManager.shared.dbManager!.database
    
    let foo = try! TypeModel.query(on: db)
      .filter(\.$typeId == item.typeID)
      .first()
      .wait()
    typeModel = foo!
    Task {
      if let materials = try? await item.$materials
        .get(on: db)
        .get()
      {
        self.materials = materials
        self.materialTypes = materials.compactMap { value in
          try! TypeModel.query(on: db)
            .filter(\.$typeId == value.materialTypeID)
            .first()
            .wait()
        }
      }
    }
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
          ForEach(viewModel.materialTypes, id: \.id) { material in
            Text("\(material.name)")
            
            //Text("\(material.quantity)")
          }
        }
        
        VStack(alignment: .leading) {
          ForEach(viewModel.materials, id: \.id) { material in
            Text("\(material.quantity)")
          }
        }
        
      }
      Text("\(viewModel.materials.count)")
    }
  }
}

//#Preview {
//    ItemMaterialDetailView(item: TypeMaterialsModel(typeID: 0))
//}
