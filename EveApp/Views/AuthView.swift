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
    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 10) {
                if let accessTokenResponse = self.$authViewModel.accessTokenResponse.wrappedValue
                {
                    Text("AccessToken: yes")
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
            LoginView()
        }
       
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
