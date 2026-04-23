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

@Observable
class DataManager {
    @State static var shared = DataManager()
    
    var redisActor: RedisActor1
    
    var dbManager: DBManager?
    var authManager: AuthManager
    
   var accessKey: String?
    var accessTokenResponse: AccessTokenResponse? = nil
    var accessTokenData: AccessTokenData?
    
    var characterData: CharacterInfo?
    
    var categoryInfoByID: [Int32: CategoryInfoResponseData] = [:]
    var groupInfoByID: [Int32: GroupInfoResponseData] = [:]
    var typesInfoByID: [Int32: GetUniverseTypesTypeIdOk] = [:]
    
    var dataLoading: Bool = false 

    
    private init() {
        authManager = AuthManager(delegate: nil)
        redisActor = RedisActor1()
        Task {
            //try? await redisActor.setup()
            await loadClientInfo()
            await loadAccessTokenData()
            await setupKBListener()
        }
        authManager.delegate = self
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
    
    func setupKBListener() async {
        print("-- setupKBListener")
        await update(redisActor)
        //await redisActor.start()
    }
    
    func dataCallback(_ data: ZKillFeedResponseWrapper) {
        print("-- dataCallback \(data.package.killID)")
        self.saveResponse(data)
        Task {
            await self.process(data: data)
        }
    }
    
    func update(_ actor: isolated RedisActor1) async {
        print("-- updateActor ")
        actor.setCallback(self.dataCallback)
    }
}

extension DataManager: AuthManagerDelegate {
    func authManager(didCompleteAuthWith authData: AuthDataResponse) {
        print("authManager didCompleteAuthWith")
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
