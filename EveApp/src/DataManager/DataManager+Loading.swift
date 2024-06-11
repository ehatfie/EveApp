//
//  DataManager+Loading.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/10/23.
//

import Foundation

/// Loading stuff from user defaults

extension DataManager {
    
    func loadAccessTokenData() {
        print("loadAccessTokenData()")
        
        guard let accessToken = accessTokenResponse?.access_token else {
            print("no access token")
            return
        }
        
        let response = decode(jwtToken: accessToken)
        let decoder = JSONDecoder()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
            
            let result = try decoder.decode(AccessTokenData.self, from: jsonData)
            self.accessTokenData = result
            print("got characterID result \(result.characterID)")
            let characterData = CharacterDataModel(characterID: result.characterID)
            Task {
                // TODO: only do if not there?
                try? await self.dbManager?.save(characterData)
            }
            // TODO: MOVE
            self.characterData = CharacterInfo(characterID: result.characterID)
        } catch let err {
            print("decode error \(err)")
        }
        
    }
    
    func getAccessTokenData1() -> [AuthModel] {
        print("loadAccessTokenData()")
        
        guard let dbManager = self.dbManager else {
            return []
        }
        guard let authModel = try? dbManager
            .database
            .query(AuthModel.self)
            .all()
            .wait()
        else {
            return []
        }
        return authModel
    }
    
    func clearAccessTokenData() {
        print("clearAccessTokenData()")
        clearAccessTokenResponse()
        
        try? dbManager?.getObjects(for: AuthModel.self)
            .delete(on: dbManager!.database)
            .wait()
    }
    
    func loadCategoryData() {
        print("loadCategoryData()")
        let categoryInfoByID = UserDefaultsHelper.loadFromUserDefaults(
            type: [Int32: CategoryInfoResponseData].self,
            key: .categoriesByIdResponse
        )
        print("done")
        self.categoryInfoByID = categoryInfoByID ?? [:]
    }
    
    func loadGroupData() async {
        print("loadGroupData()")
        try? await self.dbManager?.loadGroupData()
//        let groupInfoByID = UserDefaultsHelper.loadFromUserDefaults(
//            type: [Int32: GroupInfoResponseData].self,
//            key: .groupInfoByIdResponse
//        )
//        print("done")
//        self.groupInfoByID = groupInfoByID ?? [:]
    }
    
    func loadTypeData() async {
        print("loadTypeData()")
        try? await self.dbManager?.loadTypeData()
        return
        let typeInfoById = UserDefaultsHelper.loadFromUserDefaults(
            type: [Int32: GetUniverseTypesTypeIdOk].self,
            key: .typeInfoByIdResponse
        )
        print("done")
        self.typesInfoByID = typeInfoById ?? [:]
    }
}
