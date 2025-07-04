//
//  HomeView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/24/23.
//

import SwiftUI
import Combine
import SwiftEveAuth



@Observable class HomeViewModel2 {
  var needsAuthSetup: Bool = false
  var needsAuthentication: Bool = false
  var dataLoading: Bool = false
  
  var cancellable: AnyCancellable?
  var cancellable2: AnyCancellable?
  
  init() {
    checkForNeedsAuthSetupData()
    checkForNeedsAuthentication()
    
//    self.cancellable = AuthManager.shared
//      .$isLoggedIn
//      .sink(receiveValue: { loggedIn in
//        DispatchQueue.main.async {
//          self.needsAuthentication = !loggedIn
//        }
//
//      })
    
    //DataManager.shared.$dataLoading.assign(to: &dataLoading)
  }
  
  func checkForNeedsAuthSetupData() {
    needsAuthSetup = !UserDefaultsHelper.hasValueFor(key: .clientInfo)
    print("checkForNeedsAuth setup \(needsAuthSetup)")
  }
  
  func checkForNeedsAuthentication() {
    let hasValue = UserDefaultsHelper.hasValueFor(key: .accessTokenResponse)
    print("checkForNeedsAuthentication: hasValue \(hasValue)")
    needsAuthentication = !hasValue && !needsAuthSetup
    print("checkForNeedsAuthentication: \(needsAuthentication && !needsAuthSetup)")
  }
  
  func testFetch() {
    
  }
  
  func onAuthSubmit(clientInfo: ClientInfo) {
    DataManager.shared.setClientInfo(clientInfo: clientInfo)
    needsAuthSetup = false
  }
}

struct HomeView2: View {
  var homeViewModel: HomeViewModel2 = HomeViewModel2()
    @Environment(AppModel.self) var appModel: AppModel
  
  @State private var selectedSideBarItem: SideBarItem?
  @State private var preferredColumn: NavigationSplitViewColumn = .detail
  
  var body: some View {
    @Bindable var modelData = appModel
      
      NavigationSplitView(
        preferredCompactColumn: $preferredColumn
      ) {
          List {
              Section {
                ForEach(NavigationOptions.mainPages) { page in
                      NavigationLink(value: page) {
                        Label(page.name, systemImage: page.symbolName)
                      }
                  }
              }
          }
          .navigationDestination(for: NavigationOptions.self) { page in
              NavigationStack(path: $modelData.path) {
                  page.viewForPage()
              }
  //            .navigationDestination(for: Landmark.self) { landmark in
  //                LandmarkDetailView(landmark: landmark)
  //            }
  //            .navigationDestination(for: LandmarkCollection.self) { collection in
  //                CollectionDetailView(collection: collection)
  //            }
              //.showsBadges()
          }
  //        .frame(minWidth: 150)
      } detail: {
  //        NavigationStack(path: $modelData.path) {
  //            NavigationOptions.landmarks.viewForPage()
  //        }
  //        .navigationDestination(for: Landmark.self) { landmark in
  //            LandmarkDetailView(landmark: landmark)
  //        }
  //        .showsBadges()
      }
      .toolbar {
          ToolbarSpacer(.flexible)
          
          
          ToolbarItem {
              Button("Settings", systemImage: "gear") { }
              //ShareLink(item: landmark, preview: landmark.sharePreview)
          }
          
          
          ToolbarSpacer(.fixed)
          
          ToolbarItemGroup {
              //LandmarkFavoriteButton(landmark: landmark)
              //LandmarkCollectionsMenu(landmark: landmark)
          }
          
          ToolbarSpacer(.fixed)
          
          
          ToolbarItem {
              Button("Info", systemImage: "info") {
                  //modelData.selectedLandmark = landmark
                  //modelData.isLandmarkInspectorPresented.toggle()
              }
          }
      }
  }

}

struct HomeView_Previews2: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
