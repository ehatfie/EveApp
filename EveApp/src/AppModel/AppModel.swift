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

final class AppModel: ObservableObject {
    @ObservedObject var dbManager = DBManager()
    @ObservedObject var dataManager: DataManager
    
    
    
    init() {
        self.dataManager = DataManager.shared
        
        self.dataManager.dbManager = dbManager
        
        
        dbManager.$dbLoading
            .assign(to: &dataManager.$dataLoading)

    }
    
}
