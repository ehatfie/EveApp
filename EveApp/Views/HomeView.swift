//
//  HomeView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/24/23.
//

import SwiftUI
import Combine

enum SideBarItem: String, Identifiable, CaseIterable {
  var id: String { rawValue }
  
  case characterInfo
  case reprocessingHelper
  case skillQueue
  case itemDogmaExplorer
  case industryHelper
  case devSettings
  case auth
  case assets
  case itemExplorer
  case blueprintExplorer
  case potentialIndustry
}

@Observable class HomeViewModel {
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

struct HomeView: View {
  var homeViewModel: HomeViewModel = HomeViewModel()
  @Environment(DBManager.self) var db: DBManager
  
  @State var selectedSideBarItem: SideBarItem?
  
  var body: some View {
    body2()
      .onAppear {
        print("got dbManager \(db)")
      }
  }
  
  func body2() -> some View {
    return NavigationSplitView {
      List(SideBarItem.allCases, selection: $selectedSideBarItem) { item in
        NavigationLink(
          item.rawValue.localizedCapitalized,
          value: item
        )
      }
    } detail: {
      switch selectedSideBarItem {
      case .characterInfo:
        CharacterInfoView()
      case .assets:
        AssetsViewer()
      case .reprocessingHelper:
        ReprocessingHelperView()
      case .skillQueue:
        SkillQueueView(viewModel: SkillQueueViewModel())
      case .itemDogmaExplorer:
        ItemDogmaExplorerView(viewModel: ItemDogmaExplorerViewModel())
      case .industryHelper:
        IndustryHelperView()
          .environment(db)
      case .devSettings:
        DevelopHelperView()
          .environment(homeViewModel)
      case .auth:
        AuthView()
          .environment(homeViewModel)
      case .itemExplorer:
        ItemExplorerView(viewModel: ItemExplorerViewModel())
      case .blueprintExplorer:
        BlueprintExplorerView()
      case .potentialIndustry:
        PotentialIIndustryView(viewModel: PotentialIndustryViewModel())
      case nil:
        HomeInfoView(viewModel: HomeInfoViewModel(dbManager: db))
          .environment(db)
      }
    }
  }
  
  func body1() -> some View {
    return NavigationView {
      List {
        NavigationLink(destination: {
          CharacterInfoView()
        }, label: {
          Text("CharacterInfo")
        })
        
        NavigationLink(destination: {
          ReprocessingHelperView()
        }, label: {
          Text("Reprocessing Helper")
        })
        
        NavigationLink(destination: {
          SkillQueueView(viewModel: SkillQueueViewModel())
        }, label: {
          Text("Skill Queue")
        })
        
        NavigationLink(destination: {
          ItemDogmaExplorerView(viewModel: ItemDogmaExplorerViewModel())
        }, label: {
          Text("Item dogma explorer view")
        })
        
        NavigationLink(destination: {
          DogmaExplorerView(viewModel: DogmaExplorerViewModel())
        }, label: {
          Text("Dogma Explorer")
        })
        
        NavigationLink(destination: {
          ItemExplorerView(viewModel: ItemExplorerViewModel())
        }, label: {
          Text("Item Explorer")
        })
        
        NavigationLink(destination: {
          ItemMaterialExplorerView(viewModel: ItemMaterialExplorerViewModel())
        }, label: {
          Text("Item Material Explorer")
        })
        
        NavigationLink(destination: {
          BlueprintExplorerView()
        }, label: {
          Text("Blueprint Explorer")
        })
        
        NavigationLink(destination: {
          LoginView()
        }, label: {
          Text("Login View")
        })
        NavigationLink(destination: {
          DevelopHelperView()
            .environment(homeViewModel)
        }, label: {
          Text("Developer Helper View")
        })
      }
    }
//    }.sheet(isPresented: $homeViewModel.dataLoading, content: {
//      Text("Data Loading ...")
//        .padding()
//    })
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
