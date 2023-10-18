//
//  HomeView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/24/23.
//

import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var needsAuthSetup: Bool = false
    @Published var needsAuthentication: Bool = false
    
    var cancellable: AnyCancellable?
    
    init() {
        checkForNeedsAuthSetupData()
        checkForNeedsAuthentication()
        
        self.cancellable = AuthManager.shared
            .$isLoggedIn
            .sink(receiveValue: { loggedIn in
                DispatchQueue.main.async {
                    self.needsAuthentication = !loggedIn
                }
                
            })
    }
    
    func checkForNeedsAuthSetupData() {
        needsAuthSetup = !UserDefaultsHelper.hasValueFor(key: .clientInfo)
        print("checkForNeedsAuth setup \(needsAuthSetup)")
    }
    
    func checkForNeedsAuthentication() {
        let hasValue = UserDefaultsHelper.hasValueFor(key: .accessTokenResponse)
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
    @ObservedObject var homeViewModel: HomeViewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            List{
                NavigationLink(destination: {
                    CharacterInfoView()
                }, label: {
                    Text("CharacterInfo")
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
                    LoginView()
                }, label: {
                    Text("Login View")
                })
            }
        }
        VStack {
            HStack(alignment: .top) {
//                AuthView()
//                Spacer()
                
            }
        }.sheet(isPresented: $homeViewModel.needsAuthSetup, content: {
            AuthSetupView(onSubmit: homeViewModel.onAuthSubmit(clientInfo:))
                .frame(minWidth: 250, minHeight: 175)
        })
        .sheet(isPresented: $homeViewModel.needsAuthentication, content: {
            AuthView().frame(minWidth: 250, minHeight: 175)
        })
        
        
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
