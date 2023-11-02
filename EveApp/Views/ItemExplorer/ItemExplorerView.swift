//
//  ItemExplorerView.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/5/23.
//

import SwiftUI
import Combine

class ItemCategoryID: Identifiable {
  var id: Int32
  
  init(id: Int32) {
    self.id = id
  }
}



class ItemExplorerViewModel: ObservableObject {
  var categoryIDs: [Int32] = []
  @Binding var categories: [CategoryModel]
  //    var categories1: [CategoryModel] {
  //
  //    }
  
  var cancellable: AnyCancellable? = nil
  
  init() {
    //        cancellable = DataManager.shared
    //            .$categoryInfoByID
    //            .receive(on: RunLoop.main)
    //            .sink(receiveValue: { [weak self] categoryInfoByID in
    //                guard let self = self else { return }
    //                self.categories = self.categoryIDs
    //                    .map {
    //                        ItemCategory(
    //                            categoryId: $0,
    //                            categoryInfoResponseData: categoryInfoByID[$0]
    //                        )
    //                    }
    //            })
    
    
    _categories = Binding(get: {
      try! DataManager.shared
        .dbManager!
        .database
        .query(CategoryModel.self)
        .all()
        .wait()
    }, set: { _ in })
  }
  
  func loadCategories() {
    
  }
  
  func fetchCategories() {
    //DataManager.shared.fetchCategories()
  }
}

struct ItemExplorerView: View {
  @ObservedObject var viewModel: ItemExplorerViewModel
  
  
  var body: some View {
    VStack {
      
    }
  }
}

struct ItemExplorerView_Previews: PreviewProvider {
  static var previews: some View {
    ItemExplorerView(viewModel: ItemExplorerViewModel())
  }
}
