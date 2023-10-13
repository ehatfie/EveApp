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
        guard accessTokenData == nil else {
            print("accessTokenData loaded")
            return
        }
        
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
            print("got result \(result.characterID)")
            
            // TODO: MOVE
            self.characterData = CharacterInfo(characterID: result.characterID)
        } catch let err {
            print("decode error \(err)")
        }
        
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
    
    func loadGroupData() {
        print("loadGroupData()")
        try? self.dbManager?.loadGroupData()
//        let groupInfoByID = UserDefaultsHelper.loadFromUserDefaults(
//            type: [Int32: GroupInfoResponseData].self,
//            key: .groupInfoByIdResponse
//        )
//        print("done")
//        self.groupInfoByID = groupInfoByID ?? [:]
    }
    
    func loadTypeData() {
        print("loadTypeData()")
        try? self.dbManager?.loadTypeData()
        return
        let typeInfoById = UserDefaultsHelper.loadFromUserDefaults(
            type: [Int32: GetUniverseTypesTypeIdOk].self,
            key: .typeInfoByIdResponse
        )
        print("done")
        self.typesInfoByID = typeInfoById ?? [:]
    }
}
