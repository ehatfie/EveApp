//
//  ContentView.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/24/23.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var model: AppModel
    @State private var isShowingSheet: Bool
    
    var anyCanellable: AnyCancellable?
    
    init(model: AppModel) {
        self.model = model
        isShowingSheet = true
//        anyCanellable = model.dbManager.$dbLoading
//            .sink(receiveValue: { [self] value in
//                print("dbloading value \(value)")
//                self.isShowingSheet = value
//            })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {[self] in
            self.isShowingSheet = false
        })
    }
    
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
//                .sheet(isPresented: $isShowingSheet, content: {
//                    Text("DATA LOADING")
//                        .frame(width: 250, height: 150)
//                })
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: AppModel())
    }
}
