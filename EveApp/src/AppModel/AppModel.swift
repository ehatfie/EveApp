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
    
    init() {
        self.dataManager = DataManager.shared
        
        self.dataManager.dbManager = dbManager
        self.dataManager.authManager1.dbManager = dbManager
        
//        dbManager.$dbLoading
//            .assign(to: &dataManager.$dataLoading)

    }
    
}
