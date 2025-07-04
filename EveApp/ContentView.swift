//
//  ContentView.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/24/23.
//

import SwiftUI
import Combine

struct ContentView: View {
  @Environment(AppModel.self) var model: AppModel
  @State private var isShowingSheet: Bool
  
  var anyCanellable: AnyCancellable?
  
  init() {
    isShowingSheet = false
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      HomeView2()
        .environment(model.dbManager)
        
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
