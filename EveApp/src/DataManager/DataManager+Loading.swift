//
//  DataManager+Loading.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/10/23.
//

import Foundation
import ModelLibrary
import SwiftEveAuth

/// Loading stuff from user defaults

extension DataManager {
    
    func loadAccessTokenData() async {
        print("loadAccessTokenData()")
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
