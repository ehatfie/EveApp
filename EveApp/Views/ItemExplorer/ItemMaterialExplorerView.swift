//
//  ItemMaterialExplorerView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/20/23.
//

import SwiftUI
import Fluent
import Combine

//@MainActor
@Observable class ItemMaterialExplorerViewModel {
  var data: [TypeMaterialsModel] = []
  var searchedType: TypeModel? = nil
  
  var searchText = SearchText(text: "")
  
  init() {

  }
  
  func getData() {

  }
  
  func search() {
    let dbManager = DataManager.shared.dbManager
    
    guard let result = try? TypeModel
      .query(on: dbManager!.database)
      .filter(\.$name == searchText.text)
      .first()
      .wait()
            
    else {
      print("no search result for \(self.searchText)")
      return
    }
    
    self.searchedType = result
  }
}

@Observable final class SearchText {
  var text: String
  
  init(text: String) {
    self.text = text
  }
}

struct ItemMaterialExplorerView: View {
  @State var viewModel: ItemMaterialExplorerViewModel
  var body: some View {
    VStack {
      HStack(alignment: .top) {
        Text("Search: ")
        TextField(
          "title",
          text: $viewModel.searchText.text,
          prompt: Text("legion")
        ).frame(maxWidth: 250)
        
        Button(action: {
          viewModel.search()
        }, label: {
          Text("Submit")
        })
      }
      if let selectedType = viewModel.searchedType {
        ItemMaterialDetailView(
          viewModel: ItemMaterialDetailViewModel(
            typeModel: selectedType
          )
        )
      }
    }

  }
}

#Preview {
  ItemMaterialExplorerView(viewModel: ItemMaterialExplorerViewModel())
}
