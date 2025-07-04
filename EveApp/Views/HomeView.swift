//
//  HomeView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/24/23.
//

import SwiftUI
import Combine
import SwiftEveAuth



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
  
  @State private var selectedSideBarItem: SideBarItem?
  @State private var preferredColumn: NavigationSplitViewColumn = .detail
  
  var body: some View {
    testBody()
  }
  
  func testBody() -> some View {
    NavigationSplitView {
      List(SideBarItem.allCases, id: \.self, selection: $selectedSideBarItem) { item in
          Text(item.rawValue.localizedCapitalized)
//            .foregroundStyle(selectedSideBarItem == item ? .blue : .primary)
//            .onTapGesture {
//              if selectedSideBarItem == item {
//                selectedSideBarItem = nil // Deselect the current selection if tapped again
//              } else {
//                selectedSideBarItem = item // Select the new item
//              }
//          }
      }
    } detail: {
      Group {
        switch self.selectedSideBarItem {
        case .auth:
          AuthView()
            .environment(homeViewModel)
        case .algoHelper:
          AlgoHelperView(viewModel: AlgoHelperViewModel(dbManager: db))
        case .characterInfo:
          CharacterInfoList(viewModel: CharacterInfoListViewModel(dbManager: db))
          //CharacterInfoView()
        case .skills:
          SkillsRootView()
        case .assets:
          AssetsViewer()
        case .reprocessingHelper:
          ReprocessingHelperView()
        case .industryHelper:
          IndustryHelperView()
            .environment(db)
        case .devSettings:
          DevelopHelperView()
            .environment(homeViewModel)
        case .blueprintExplorer:
          ItemViewerRootView()
        case .potentialIndustry:
          PotentialIIndustryView(viewModel: PotentialIndustryViewModel())
        case .reactionHelper:
          ReactionHelperView()
        case .killboard:
          KillboardView()
          //            KillboardViewOLD()
        case .characterIndustryView:
          CharacterIndustryView(viewModel: CharacterIndustryViewModel())
        case .industryPlanner:
          IndustryPlannerView(viewModel: IndustryPlannerViewModel())
        case .wallet:
          WalletRootView(dbManager: db)
        case .search:
          SearchRootView()
          //      case nil:
          //        AlgoHelperView(viewModel: AlgoHelperViewModel(dbManager: db))
          //        HomeInfoView(viewModel: HomeInfoViewModel(dbManager: db))
          //          .environment(db)
        default: EmptyView()
        }
      }.glassEffect()
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
