//
//  AuthSetupView.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/3/23.
//

import SwiftUI
import SwiftEveAuth

struct AuthSetupView: View {
    @State var clientID: String = ""
    @State var secretKey: String = ""
    @State var callbackURL: String = ""
    
    let onSubmit: (ClientInfo) -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Enter your stuff")
            TextField(text: $clientID, label: {
                Text("Client ID")
            })
            
            TextField(text: $secretKey, label: {
                Text("Secret Key")
            })
            
            TextField(text: $callbackURL, label: {
                Text("Callback URL")
            })
            
            if !clientID.isEmpty
            && !secretKey.isEmpty
            && !callbackURL.isEmpty {
                Button(action: {
                    submit()
                    clientID = ""
                    secretKey = ""
                    callbackURL = ""
                }, label: {
                    Text("Submit")
                })
            }
        }
        .frame(maxWidth: 200)
        .padding()
    }
    
    func submit() {
        let clientInfo = ClientInfo(clientID: clientID, secretKey: secretKey, callbackURL: callbackURL)
        self.onSubmit(clientInfo)
        //DataManager.shared.setClientInfo(clientInfo: clientInfo)
    }
}

struct AuthSetupView_Previews: PreviewProvider {
    static var previews: some View {
        AuthSetupView(onSubmit: { _ in })
    }
}
