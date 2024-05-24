//
//  DataManager.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/7/23.
//

import Foundation
import SwiftUI

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
        DispatchQueue.main.async { [self] in
            loadClientInfo()
            loadAccessTokenResponse()
            loadAccessTokenData()
            loadCharacterData()
//            loadCategoryData()
//            loadGroupData()
//            loadTypeData()
        }
        
    }
    
    func useAccessKey(_ value: String) {
        self.accessKey = value
        
        AuthManager.shared.outhAuthorize(authCode: value)
    }
    
    func loadAccessTokenResponse() {
        guard let foo = UserDefaultsHelper.loadFromUserDefaults(
            type: AccessTokenResponse.self,
            key: UserDefaultKeys.accessTokenResponse.rawValue
        ) else {
            print("didnt get objects")
            return
        }
        
        self.accessTokenResponse = foo
        AuthManager.shared.isLoggedIn = true
    }
    
    func loadCharacterData() {
        
    }
    
    
    func refreshToken() {
        AuthManager.shared.refresh()
    }
    
    func setCharacterPublicData(data: CharacterPublicDataResponse) {
        
    }

}


