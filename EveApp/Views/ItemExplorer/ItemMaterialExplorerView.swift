//
//  ItemMaterialExplorerView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/20/23.
//

import SwiftUI
import Fluent

@MainActor
class ItemMaterialExplorerViewModel: ObservableObject {
  @Published var data: [TypeMaterialsModel] = []
  @Published var searchedType: TypeModel? = nil
  
  @Published var searchText: String = ""
  
  init() {
    //        Planet.query(on: database).with(\.$star).all().map { planets in
    //            for planet in planets {
    //                // `star` is accessible synchronously here
    //                // since it has been eager loaded.
    //                print(planet.star.name)
    //            }
    //        }
    //        Task {
    //            if let foo = try? await TypeMaterialsModel
    //                .query(on: DataManager.shared.dbManager!.database)
    //                .with(\.$materials).all().get() {
    //                self.data = foo
    //            }
    //        }
    //        try? TypeMaterialsModel
    //            .query(on: DataManager.shared.dbManager!.database)
    //            .with(\.$materials).all().map { value in
    //                self.data = value
    //            }.wait()
  }
  
  func getData() {
//    Task {
//      let dbManager = DataManager.shared.dbManager
//      
//      let results = try! await TypeMaterialsModel.query(on: dbManager!.database)
//        .all()
//        .get()
//      
//      self.data = results
//    }
    
  }
  
  func search() {
    let dbManager = DataManager.shared.dbManager
    
    guard let result = try? TypeModel
      .query(on: dbManager!.database)
      .filter(\.$name == searchText)
      .first()
      .wait()
            
    else {
      print("no search result for \(self.searchText)")
      return
    }
    
    self.searchedType = result
  }
}

struct ItemMaterialExplorerView: View {
  @ObservedObject var viewModel: ItemMaterialExplorerViewModel
  var body: some View {
    VStack {
      HStack(alignment: .top) {
        Text("Search: ")
        TextField(
          "title",
          text: $viewModel.searchText,
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
