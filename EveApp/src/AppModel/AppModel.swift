//
//  AppModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Foundation
import SwiftUI
import Combine

import NIO
import Fluent
import ModelLibrary

@Observable final class AppModel {
    var dbManager = DBManager()
    var dataManager: DataManager
    
    var needsAuthSetup: Bool = false
    var listenerEnabled: Bool = false
    
    var path: NavigationPath = NavigationPath() {
        didSet {
            // Check if the person navigates away from a view that's showing the inspector.
//            if path.count < oldValue.count && isLandmarkInspectorPresented == true {
//                // Dismiss the inspector.
//                isLandmarkInspectorPresented = false
//            }
        }
    }
    
    var characterModels: [CharacterInfoDisplayable] = []
    
    init() {
        let start = Date()
        print("++ AppModel init start")
        self.dataManager = DataManager.shared
        
        self.dataManager.dbManager = dbManager
        //self.dataManager.authManager.dbManager = dbManager
        print("++ AppModel init done \(Date().timeIntervalSince(start))")
//        dbManager.$dbLoading
//            .assign(to: &dataManager.$dataLoading)
        loadCharacterModels()
    }
    
    // this goes in a store?
    func loadCharacterModels() {
        Task {
            let models = await dbManager.getCharacterInfoDisplayable()
            self.characterModels = models
        }
    }
    
    func updateListener() {
        //self.listenerEnabled.toggle()
        
        if listenerEnabled {
            self.dataManager.startListener()
        } else {
            self.dataManager.stopListener()
        }
    }
}
