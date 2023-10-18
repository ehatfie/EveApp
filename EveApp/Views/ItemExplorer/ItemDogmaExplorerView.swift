//
//  ItemDogmaExplorerView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/14/23.
//

import SwiftUI
import Fluent

class ItemDogmaExplorerViewModel: ObservableObject {
  @Published var data: [TypeDogmaInfoModel] = []
  
  init() {
    let dbManager = DataManager.shared.dbManager
    
    let results = try! TypeDogmaInfoModel.query(on: dbManager!.database)
      .all()
      .wait()
    print("ItemDogmaExplorerViewModel data count \(results.count)")
    self.data = results
  }
  
  func getData() {
    let dbManager = DataManager.shared.dbManager
    
    let results = try! TypeDogmaInfoModel.query(on: dbManager!.database)
      .all()
      .wait()
    print("ItemDogmaExplorerViewModel data count \(results.count)")
    self.data = results
  }
}

struct ItemDogmaExplorerView: View {
  @ObservedObject var viewModel: ItemDogmaExplorerViewModel
  
    var body: some View {
      List($viewModel.data, id: \.id) { typeDogmaInfoModel in
        HStack {
          Text("\(typeDogmaInfoModel.typeId.wrappedValue)")
          Text("attributes: \(typeDogmaInfoModel.attributes.count)")
          Text("effects: \(typeDogmaInfoModel.effects.count)")
        }
      }.onAppear{
        viewModel.getData()
      }
    }
}

#Preview {
  ItemDogmaExplorerView(viewModel: ItemDogmaExplorerViewModel())
}
