//
//  LoginView.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/24/23.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var accessKey: String?
    
    init() {
        DataManager.shared
            .$accessKey
            .assign(to: &$accessKey)
    }
    
    func login() {
        DataManager.shared.authManager1.login()
    }
    
    func refreshToken() {
        //LoginManager.shared
    }
}

struct LoginView: View {
    @ObservedObject var loginViewModel = LoginViewModel()
    
    var body: some View {
        Text("Lets get Authenticated")
        
        Button(action: {
            loginViewModel.login()
        }, label: {
            Text("login")
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
