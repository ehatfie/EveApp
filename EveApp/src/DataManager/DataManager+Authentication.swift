//
//  DataManager+Authentication.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/3/23.
//

import Foundation

struct ClientInfo: Codable {
    let clientID: String
    let secretKey: String
    let callbackURL: String
}

extension DataManager {
    
    func setClientInfo(clientInfo: ClientInfo) {
        // set into user defaults
        UserDefaultsHelper.saveToUserDefaults(
            data: clientInfo,
            key: .clientInfo
        )
    }
    
    func loadClientInfo() {
        guard let clientInfo = UserDefaultsHelper.loadFromUserDefaults(
            type: ClientInfo.self,
            key: UserDefaultKeys.clientInfo.rawValue
        ) else {
            print("no client info")
            return
        }
        AuthManager.shared.setClientInfo(clientInfo: clientInfo)
        print("got client info \(clientInfo)")
        
    }
}
