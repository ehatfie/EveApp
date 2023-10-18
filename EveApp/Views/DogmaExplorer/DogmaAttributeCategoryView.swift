//
//  DogmaAttributeCategoryView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/13/23.
//

import SwiftUI
import Fluent

class DogmaAttributeCategoryViewModel: ObservableObject {
  var dogmaAttributeCategory: DogmaAttributeCategoryModel
  var dogmaAttributes: [DogmaAttributeModel] = []
  
  init(dogmaAttributeCategory: DogmaAttributeCategoryModel) {
    self.dogmaAttributeCategory = dogmaAttributeCategory
    
    let dbManager = DataManager.shared.dbManager
    
    let results = try! DogmaAttributeModel.query(on: dbManager!.database)
      .filter(\.$categoryID == Int(dogmaAttributeCategory.categoryId))
      .all()
      .wait()
    self.dogmaAttributes = results
  }
}

struct DogmaAttributeCategoryView: View {
  @ObservedObject var viewModel: DogmaAttributeCategoryViewModel
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("\(viewModel.dogmaAttributeCategory.categoryId)")
        Text(viewModel.dogmaAttributeCategory.categoryDescription)
      }
      
      Text(viewModel.dogmaAttributeCategory.categoryDescription)
      
      List($viewModel.dogmaAttributes, id: \.id) { dogmaAttributeModel in
        DogmaAttributeDetailView(dogmaAttribute: dogmaAttributeModel)
      }.frame(minHeight: 100)

//      List {
//        ForEach($viewModel.dogmaAttributes, id: \.id) { dogmaAttributeModel in
//          DogmaAttributeDetailView(dogmaAttribute: dogmaAttributeModel)
//        }
//      }
    }.padding(10)
  }
}

#Preview {
  DogmaAttributeCategoryView(
    viewModel:
      DogmaAttributeCategoryViewModel(
        dogmaAttributeCategory: DogmaAttributeCategoryModel()
      )
  )
}
