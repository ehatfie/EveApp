//
//  ContentView.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/24/23.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack(alignment: .leading) {
//            if AuthManager.shared.clientInfo == nil {
//                AuthSetupView()
//            } else {
//                HStack(alignment: .top) {
//                    AuthView()
//                    Spacer()
//                    CharacterInfoView()
//                    AuthSetupView()
//                }
//            }
           HomeView()
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
