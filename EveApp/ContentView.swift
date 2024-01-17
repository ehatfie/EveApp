//
//  ContentView.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/24/23.
//

import SwiftUI
import Combine

struct ContentView: View {
  @ObservedObject var model: AppModel
  @State private var isShowingSheet: Bool
  
  var anyCanellable: AnyCancellable?
  
  init(model: AppModel) {
    self.model = model
    isShowingSheet = false
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      HomeView()
        .environmentObject(model.dbManager)
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(model: AppModel())
  }
}
