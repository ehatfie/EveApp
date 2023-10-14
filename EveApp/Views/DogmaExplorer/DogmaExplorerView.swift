//
//  DogmaExplorerView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/12/23.
//

import SwiftUI
import Fluent

class DogmaExplorerViewModel: ObservableObject {
  var dogmaEffect: [DogmaEffectModel] = []
  var dogmaAttributes: [DogmaAttributeModel] = []
  var dogmaAttributeCategories: [DogmaAttributeCategoryModel] = []
  
  init() {
    let dbManager = DataManager.shared.dbManager
    
    do {
      let dogmaEffect = try DogmaEffectModel.query(on: dbManager!.database)
        .all()
        .wait()
      
      let dogmaAttribute = try DogmaAttributeModel.query(on: dbManager!.database)
        .all()
        .wait()
      
      let dogmaAttributeCategoryModels = try DogmaAttributeCategoryModel.query(on: dbManager!.database)
        .all()
        .wait()
      
      print("got \(dogmaEffect.count) dogma effect")
      self.dogmaEffect = dogmaEffect
      self.dogmaAttributes = dogmaAttribute
      self.dogmaAttributeCategories = dogmaAttributeCategoryModels
      
    } catch let error {
      print("dogma explorer init error \(error)")
    }
    
  }
}

struct DogmaExplorerView: View {
  @ObservedObject var viewModel: DogmaExplorerViewModel
  
  var body: some View {
    VStack {
     // HStack {
        //        List {
        //          ForEach($viewModel.dogmaEffect, id: \.id) { dogmaEffect in
        //            DogmaEffectView(dogmaEffect: dogmaEffect)
        //          }
        //        }
        //        List {
        //          ForEach($viewModel.dogmaAttributes, id: \.id) { dogmaAttribute in
        //            if let viewModel = DogmaAttributeViewModel(
        //              dogmaAttribute: dogmaAttribute.wrappedValue
        //            ) {
        //              DogmaAttributeView(viewModel: viewModel)
        //            }
        //          }
        //        }
        //      }
        List($viewModel.dogmaAttributeCategories, id: \.id) { dogmaAttributeCategoryModel in
            DogmaAttributeCategoryView(
              viewModel:DogmaAttributeCategoryViewModel(
                dogmaAttributeCategory: dogmaAttributeCategoryModel.wrappedValue
              )
            )
            
          
        }.padding(5)
      //}
    }
  }
}

#Preview {
  DogmaExplorerView(viewModel: DogmaExplorerViewModel())
}
