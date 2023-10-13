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
  
  init() {
    let dbManager = DataManager.shared.dbManager
    
    do {
      let dogmaEffect = try DogmaEffectModel.query(on: dbManager!.database)
        .all()
        .wait()
      
      let dogmaAttribute = try DogmaAttributeModel.query(on: dbManager!.database)
        .all()
        .wait()
      
      print("got \(dogmaEffect.count) dogma effect")
      self.dogmaEffect = dogmaEffect
      self.dogmaAttributes = dogmaAttribute
    } catch let error {
      print("dogma explorer init error \(error)")
    }
    
  }
}

struct DogmaExplorerView: View {
  @ObservedObject var viewModel: DogmaExplorerViewModel
  
  var body: some View {
    VStack {
      HStack {
        List {
          ForEach($viewModel.dogmaEffect, id: \.id) { dogmaEffect in
            DogmaEffectView(dogmaEffect: dogmaEffect)
          }
        }
        List {
          ForEach($viewModel.dogmaAttributes, id: \.id) { dogmaAttribute in
            DogmaAttributeView(dogmaAttribute: dogmaAttribute)
          }
        }
      }
    }
  }
}

#Preview {
  DogmaExplorerView(viewModel: DogmaExplorerViewModel())
}
