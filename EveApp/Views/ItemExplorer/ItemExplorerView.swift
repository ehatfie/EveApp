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
  @Published var categories: [CategoryModel]
  
  @Published var selectedCategory: CategoryModel?
  @Published var selectedGroup: GroupModel?
  @Published var selectedType: TypeModel?
  
  var cancellable: AnyCancellable? = nil
  
  init() {
    categories = try! DataManager.shared
      .dbManager!
      .database
      .query(CategoryModel.self)
      .sort(\.$categoryId)
      .all()
      .wait()
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
      Text("ItemExplorerView")
      HStack {
        List(viewModel.categories, id: \.categoryId) { category in
          categoryRow(
            category: category,
            isSelected: viewModel.selectedCategory?.categoryId == category.categoryId
          )
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .onTapGesture {
            viewModel.selectedCategory = category
            viewModel.selectedGroup = nil
            viewModel.selectedType = nil
          }
        }.frame(maxWidth: 200)
        CategoryInfoView(
          selectedCategory: $viewModel.selectedCategory,
          selectedGroup: $viewModel.selectedGroup
        )
        .frame(maxWidth: 200)
        GroupInfoView(
          selectedGroup: $viewModel.selectedGroup,
          selectedType: $viewModel.selectedType
        ).frame(maxWidth: 100)
        
        TypeInfoView(selectedType: $viewModel.selectedType)
          .frame(maxWidth: 500)
        
        
        Spacer()
      }
      
    }
    
  }
  
  func categoryRow(category: CategoryModel, isSelected: Bool) -> some View {
    return HStack {
      Text(category.name)
      Text("\(category.categoryId)")
    }.border(
      viewModel.selectedCategory?.categoryId == category.categoryId ? .red: .clear
    )
  }
}

struct ItemExplorerView_Previews: PreviewProvider {
  static var previews: some View {
    ItemExplorerView(viewModel: ItemExplorerViewModel())
  }
}
