//
//  AuthView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/27/23.
//

import SwiftUI
import TestPackage1

class AuthViewModel: ObservableObject {
    @Published var accessTokenResponse: AccessTokenResponse?
    @Published var authModels: [AuthModel] = []
    
    init() {
        DataManager
            .shared
            .$accessTokenResponse
            .assign(to: &$accessTokenResponse)
    }
    
    func loadAccessTokenData() {
        authModels = DataManager.shared.getAccessTokenData1()
    }
    
    func refreshAccessTokenData() {
        Task {
            try? await DataManager.shared.authManager1.refreshTokens()
        }
        
    }
}

struct AuthView: View {
    @ObservedObject var authViewModel = AuthViewModel()
    @Environment(HomeViewModel.self) var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 10) {
                authDataView(data: authViewModel.authModels)
            }
            .frame(maxWidth: 250)
            .border(.red)
            Button(action: {
                self.authViewModel.loadAccessTokenData()
            }, label: {
                Text("load local accessTokenData")
            })
            Button(action: {
                DataManager.shared.clearAccessTokenData()
            }, label: {
                Text("clear local accessTokenData")
            })
            
            Button(action: {
                self.authViewModel.refreshAccessTokenData()
            }, label: {
                Text("Refresh AccessToken")
            })


            LoginView()
            
            if homeViewModel.needsAuthSetup {
                authSetupView()
            }
        }
       
    }
    
    func authDataView(data: [AuthModel]) -> some View {
        VStack {
            ForEach(data, id: \.characterId) { authModel in
                Text("CharacterId: \(authModel.characterId)")
                Text("Expires on: \(Date(timeIntervalSinceReferenceDate: TimeInterval(authModel.expiration)))")
                Text("RefreshToken \(authModel.refreshToken)")
                Text("TokenType: \(authModel.tokenType)")
            }
        }
    }
    
    func authSetupView() -> some View {
        
        VStack {
            Text("Auth Setup Needed")
            AuthSetupView(onSubmit: { clientInfo in
                DataManager.shared.setClientInfo(clientInfo: clientInfo)
                AuthManager.shared.setClientInfo(clientInfo: clientInfo)
                
            })
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
