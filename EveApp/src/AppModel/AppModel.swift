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

@Observable final class AppModel {
    var dbManager = DBManager()
    var dataManager: DataManager
    
    var needsAuthSetup: Bool = false
    
    var path: NavigationPath = NavigationPath() {
        didSet {
            // Check if the person navigates away from a view that's showing the inspector.
//            if path.count < oldValue.count && isLandmarkInspectorPresented == true {
//                // Dismiss the inspector.
//                isLandmarkInspectorPresented = false
//            }
        }
    }
    
    init() {
        let start = Date()
        print("++ AppModel init start")
        self.dataManager = DataManager.shared
        
        self.dataManager.dbManager = dbManager
        //self.dataManager.authManager.dbManager = dbManager
        print("++ AppModel init done \(Date().timeIntervalSince(start))")
//        dbManager.$dbLoading
//            .assign(to: &dataManager.$dataLoading)

    }
    
}
