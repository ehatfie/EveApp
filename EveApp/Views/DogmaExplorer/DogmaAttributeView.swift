//
//  DogmaAttributeView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/12/23.
//

import SwiftUI
import Fluent

class DogmaAttributeViewModel: ObservableObject {
  var dogmaAttribute: DogmaAttributeModel
  var dogmaAttributeCategory: DogmaAttributeCategoryModel
  
  init?(dogmaAttribute: DogmaAttributeModel) {
    self.dogmaAttribute = dogmaAttribute
    let dbManager = DataManager.shared.dbManager
    
    guard let categoryId = dogmaAttribute.categoryID else {
      self.dogmaAttributeCategory = DogmaAttributeCategoryModel()
      return nil
    }
    
    var dogmaAttributeCategoryModel: DogmaAttributeCategoryModel = DogmaAttributeCategoryModel()
    
    //self.dogmaAttributeCategory = dogmaAttributeCategoryModel
    
    //do {
      self.dogmaAttributeCategory = try! DogmaAttributeCategoryModel.query(on: dbManager!.database)
        .filter(\.$categoryId == Int64(categoryId))
        .first()
        .wait()!
      
      
    //print("got \(dogmaAttributeCategoryModel)")
//    } catch let err {
//      print("DogmaAttributeViewModel init err \(err)")
//    }
  }
}

struct DogmaAttributeView: View {
    @ObservedObject var viewModel: DogmaAttributeViewModel
    
    init(viewModel: DogmaAttributeViewModel) {
      self.viewModel = viewModel
    }
    
    var body: some View {
      VStack(alignment: .leading) {
        HStack {
          Text("\(viewModel.dogmaAttribute.attributeID)")
          Text(viewModel.dogmaAttribute.name)
        }
        
        Text(viewModel.dogmaAttribute.attributeDescription ?? "")
        
        HStack {
          Text("\(viewModel.dogmaAttributeCategory.categoryId)")
          Text(viewModel.dogmaAttributeCategory.name)
        }
      }
      
    }
}

//#Preview {
//    DogmaAttributeView(dogmaAttribute: Binding(get: {
//        DogmaAttributeModel()
//    }, set: { _ in     }))
//}
