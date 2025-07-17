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
    VStack(alignment: .center) {
      HomeView2()
        .environment(model.dbManager)
    }
    //.padding()
//    .toolbar {
//        ToolbarSpacer(.flexible)
//        
//        
//        ToolbarItemGroup {
//            Button("Character One", systemImage: "person.circle") { }
//            Button("Character Two", systemImage: "person.circle") { }
//            //LandmarkFavoriteButton(landmark: landmark)
//            //LandmarkCollectionsMenu(landmark: landmark)
//        }
//        
//        ToolbarSpacer(.fixed)
//        
//        ToolbarItem {
//            Button("Settings", systemImage: "gear") { }
//            //ShareLink(item: landmark, preview: landmark.sharePreview)
//        }
//        
//        ToolbarSpacer(.fixed)
//        
//        
//        ToolbarItem {
//            Button("Info", systemImage: "info") {
//                //modelData.selectedLandmark = landmark
//                //modelData.isLandmarkInspectorPresented.toggle()
//            }
//        }
//    }
    .toolbar(removing: .title)
    .ignoresSafeArea(edges: .top)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
