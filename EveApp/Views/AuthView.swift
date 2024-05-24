//
//  AuthView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/27/23.
//

import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var accessTokenResponse: AccessTokenResponse?
    
    init() {
        DataManager
            .shared
            .$accessTokenResponse
            .assign(to: &$accessTokenResponse)
    }
}

struct AuthView: View {
    @ObservedObject var authViewModel = AuthViewModel()
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 10) {
                if let accessTokenResponse = self.authViewModel.accessTokenResponse
                {
                    Text("AccessToken: \(accessTokenResponse.access_token)")
                        .truncationMode(.head)
                        .frame(maxWidth: 500)
                    Text("Expires in: \(accessTokenResponse.expires_in)")
                    Text("RefreshToken \(accessTokenResponse.refresh_token)")
                    Text("TokenType: \(accessTokenResponse.token_type)")
                    
                    HStack {
                        Button(action: {
                            DataManager.shared.refreshToken()
                        }, label: {
                            Text("Refresh")
                        })
                    }
                }
            }
            .frame(maxWidth: 250)
            .border(.red)
            Button(action: {
                DataManager.shared.loadAccessTokenData()
            }, label: {
                Text("load local accessTokenData")
            })
            Button(action: {
                DataManager.shared.loadAccessTokenData()
            }, label: {
                Text("clear local accessTokenData")
            })

            LoginView()
            
            if homeViewModel.needsAuthSetup {
                authSetupView()
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
