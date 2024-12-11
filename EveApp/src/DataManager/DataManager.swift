//
//  DataManager.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/7/23.
//

import Foundation
import SwiftUI
import ModelLibrary
import SwiftEveAuth

struct AccessKeyKey: EnvironmentKey {
    static var defaultValue: String? {
        return nil
    }
}


extension EnvironmentValues {
    var accessKey: String? {
        get {
            self[AccessKeyKey.self]
        }
        set {
            self[AccessKeyKey.self] = newValue
        }
    }
}

class DataManager: ObservableObject {
    @ObservedObject static var shared = DataManager()
    
    var dbManager: DBManager?
    var authManager: AuthManager
    
    @Published var accessKey: String?
    @Published var accessTokenResponse: AccessTokenResponse? = nil
    @Published var accessTokenData: AccessTokenData?
    
    @Published var characterData: CharacterInfo?
    
    @Published var categoryInfoByID: [Int32: CategoryInfoResponseData] = [:]
    @Published var groupInfoByID: [Int32: GroupInfoResponseData] = [:]
    @Published var typesInfoByID: [Int32: GetUniverseTypesTypeIdOk] = [:]
    
    @Published var dataLoading: Bool = false 

    
    @Environment(\.accessKey) var accessKey1: String?
    
    private init() {
        authManager = AuthManager(delegate: nil)
        Task {
            await loadClientInfo()
            await loadAccessTokenData()
        }
    }
    
    func useAccessKey(_ value: String) {
        self.accessKey = value
        self.authManager.oauthAuthorize(authCode: value)
    }
    
    func clearAccessTokenResponse() {
        print("clearAccessTokenResponse")
        self.accessTokenResponse = nil
        //AuthManager2.shared.isLoggedIn = false
        // will eventually delete from DB also
    }
    
    
    func refreshToken() async {
        print("DataManager().refreshToken")
        do {
            let authModels = await dbManager?.getAllAuthModels()
            try await authManager.refreshTokens(authDatas: [])
        } catch let err {
            print("refresh token auth \(err)")
        }
       
        //AuthManager2.shared.refresh()
    }

}



extension DataManager: AuthManagerDelegate {
    func authManager(didCompleteAuthWith authData: AuthDataResponse) {
              Task {
                // update/create characterModel
                  await self.dbManager?.createCharacterData(accessTokenData: authData.accessTokenData)
                  await self.dbManager?.updateAccessToken(
                    response: authData.accessTokenResponse,
                    accessTokenData: authData.accessTokenData
                  )
              }
    }
    
    
}
