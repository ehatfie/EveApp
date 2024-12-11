//
//  DataManager+Fetching.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/27/23.
//

import Foundation
import ModelLibrary
import SwiftEveAuth

extension DataManager {
  func fetchCharacterInfo() {
    print("fetchCharacterInfo()")
    Task {
      //try? await fetchCharacterInfoAsync()
    }
   
//    makeApiCall1(dataEndpoint: "") { data, response, error in
//      if let data = data {
//        do {
//          let characterPublicData = try JSONDecoder().decode(CharacterPublicDataResponse.self, from: data)
//          print("got json data \(characterPublicData)")
//          DispatchQueue.main.async {
//            self.processCharacterPublicData(response: characterPublicData)
//          }
//          
//        } catch let err {
//          print("got err \(err)")
//        }
//        
//      }
//    }
  }
  
  func fetchSkillQueue() async {
    print("FetchSkillQueue()")
    
    await makeApiCall1(dataEndpoint: "skillqueue/") { data, response, error in
      if let response = response {
        //print("got response \(response)")
      }
      if let data = data {
        do {
          let foo = String(data: data, encoding: .utf8)
          print("FOO \(foo)")
          let characterSkillQueueDataResponse = try JSONDecoder().decode([CharacterSkillQueueDataResponse].self, from: data)
          
          DispatchQueue.main.async {
            self.processSkillQueue(response: characterSkillQueueDataResponse)
          }
          
        } catch let err {
          print("got err \(err)")
        }
        
      }
      
      if let response = response {
        //print("Task got response \(response)")
      }
      
      if let error = error {
        print("Task got error \(error)")
      }
      
    }
  }
  
  func fetchCategories() async {
    try? await self.dbManager?.loadCategoryData()
    print("fetchCategories()")
    
    return
    //        makeApiCall(dataEndpoint: "universe/categories", completion: { data, response, error in
    //            do {
    //                let decoder = JSONDecoder()
    //                let categoryDataResponse = try decoder.decode([Int32].self, from: data!)
    //
    //                UserDefaultsHelper.saveToUserDefaults(
    //                    data: categoryDataResponse,
    //                    key: .categoryDataResponse
    //                )
    //                print("got categories \(categoryDataResponse)")
    //                //completion(categoryDataResponse)
    //            } catch let error {
    //                print(error)
    //            }
    //        })
  }
  
  func fetchCategoriesByID() {
    print("fetchCategoriesByID()")
    guard let categoryIds = UserDefaultsHelper.loadFromUserDefaults(type: [Int32].self, key: UserDefaultKeys.categoryDataResponse.rawValue)
    else {
      print("no existing category ids")
      return
    }
    
    var categoryInfoByID = UserDefaultsHelper.loadFromUserDefaults(type: [Int32: CategoryInfoResponseData].self, key: .categoriesByIdResponse) ?? [:]
    print("got categoriesByID: \(categoryInfoByID)")
    guard categoryInfoByID[categoryIds[4]] == nil else {
      return
    }
    let endpoint = "universe/categories/\(categoryIds[4])"
//    makeApiCall(dataEndpoint: endpoint, completion: { data, response, error in
//
//      if let data = data {
//        do {
//          let decoder = JSONDecoder()
//          let categoryInfoResponse = try decoder.decode(CategoryInfoResponseData.self, from: data)
//          
//          categoryInfoByID[categoryInfoResponse.category_id] = categoryInfoResponse
//          
//          UserDefaultsHelper.saveToUserDefaults(data: categoryInfoByID, key: .categoriesByIdResponse)
//          
//          self.categoryInfoByID = categoryInfoByID
//          print("categoryInfoResponse \(categoryInfoResponse)")
//        } catch let err {
//          print(err)
//        }
//        
//      }
//    })
  }
  
  @MainActor func fetchCategoryInfoFor(categoryID: Int32) {
    print("Fetch category info For \(categoryID)")
    guard self.categoryInfoByID[categoryID] == nil else {
      print("Already fetched category info for \(categoryID)")
      return
    }
    
    UniverseAPI.getUniverseCategoriesCategoryId(categoryId: Int(categoryID), completion: { response, error in
      if let response = response {
        print("got categoryID respone \(response)")
      }
      
      if let error = error {
        print("got categooryID error \(error)")
      }
    })
    
    //        let endpoint = "universe/categories/\(categoryID)"
    //        makeApiCall(dataEndpoint: endpoint, completion: { data, response, error in
    //            if let data = data {
    //                do {
    //                    let decoder = JSONDecoder()
    //                    let categoryInfoResponse = try decoder.decode(CategoryInfoResponseData.self, from: data)
    //
    //                    var categoryInfoById = self.categoryInfoByID
    //
    //                    categoryInfoById[categoryInfoResponse.category_id] = categoryInfoResponse
    //
    //                    UserDefaultsHelper.saveToUserDefaults(
    //                        data: categoryInfoById,
    //                        key: .categoriesByIdResponse
    //                    )
    //
    //                    self.categoryInfoByID = categoryInfoById
    //                    print("categoryInfoResponse \(categoryInfoResponse)")
    //                } catch let err {
    //                    print(err)
    //                }
    //
    //            }
    //        })
  }
  
  func fetchGroupIDs() {
    print("fetchGroupIDs()")
    guard !UserDefaultsHelper.hasValueFor(key: .groupDataResponse) else {
      print("groups exist locally")
      //fetchCategoriesByID()
      return
    }
    
    //        makeApiCall(dataEndpoint: "universe/categories", completion: { data, response, error in
    //            do {
    //                let decoder = JSONDecoder()
    //                let categoryDataResponse = try decoder.decode([Int32].self, from: data!)
    //
    //                UserDefaultsHelper.saveToUserDefaults(
    //                    data: categoryDataResponse,
    //                    key: .categoryDataResponse
    //                )
    //                print("got categories \(categoryDataResponse)")
    //                //completion(categoryDataResponse)
    //            } catch let error {
    //                print(error)
    //            }
    //        })
  }
  
  
  
  
  func makeApiCall1(dataEndpoint: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) async {
    print("makeApiCall1()")
    await loadAccessTokenData()
    
    guard let accessToken = accessTokenResponse?.access_token else {
      print("ERROR - no acess token")
      return
    }
    guard let accessTokenData = self.accessTokenData else {
      print("ERROR - no access token data")
      return
    }
    
    let endpoint = "https://esi.evetech.net/latest"
    
    let characterID = accessTokenData.characterID
    let characterEndpoint = "/characters/\(characterID)/"
    
    let url = URL(string: endpoint + characterEndpoint + dataEndpoint)!
    print("url \(url)")
    var urlRequest = URLRequest(url: url)
    
    let headers: [String:String] = [
      "Authorization": "Bearer \(accessToken)"
    ]
    
    urlRequest.allHTTPHeaderFields = headers
    
    let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: completion)
    
    task.resume()
  }
  
  func makeApiCallAsync1(dataEndpoint: String) async -> (Data, URLResponse)? {
    await loadAccessTokenData()
    
    guard let accessToken = accessTokenResponse?.access_token else {
      print("ERROR - no acess token")
      return nil
    }
    guard let accessTokenData = self.accessTokenData else {
      print("ERROR - no access token data")
      return nil
    }
    
    let endpoint = "https://esi.evetech.net/latest"
    
    let characterID = accessTokenData.characterID
    let characterEndpoint = "/characters/\(characterID)/"
    let urlString = endpoint + characterEndpoint + dataEndpoint
    let url = URL(string: urlString)!
    var url1 = URLComponents(string: urlString)!
    
    url1.queryItems = APIHelper.mapValuesToQueryItems([
                    "page": 10
    ])
    
    print("url \(url)")
    print("url1 \(url1.string)")
    var urlRequest = URLRequest(url: url1.url!)
    
    let headers: [String:String] = [
      "Authorization": "Bearer \(accessToken)"
    ]
    
    urlRequest.allHTTPHeaderFields = headers
    
    do {
      return try await URLSession.shared.data(for: urlRequest)
    } catch let err {
      print("async api call error \(err)")
    }
    return nil
  }
  
  func makeApiCallAsync(dataEndpoint: String, authModel: AuthModel, page: Int? = nil) async -> (Data, URLResponse)?  {
    let urlRequest = requestBuilder(dataEndpoint: dataEndpoint, authModel: authModel, page: page)
    print("makeApiCallAsync1() - urlRequest \(urlRequest?.url?.string)")
    do {
      return try await URLSession.shared.data(for: urlRequest!)
    } catch let err {
      print("async api call error \(err)")
    }
    return nil
  }
  
  func processCharacterPublicData(response: CharacterPublicDataResponse) {
    let characterData = self.characterData
    characterData?.publicData = response
    self.characterData = characterData
    let characterPublicData = CharacterPublicDataModel(response: response)
    
    let foo = try!
    self.dbManager!
      .database
      .query(CharacterDataModel.self)
      .first()
      .wait()
    do {
      try foo?.$publicData.create(characterPublicData, on: dbManager!.database).wait()
    } catch let err {
      print("save item error \(err)")
    }
    
    print("processCharacterPublicData \(response)")
  }
  
  func processSkillQueue(response: [CharacterSkillQueueDataResponse]) {
    let characterData = self.characterData
    characterData?.skillQueue = response
    self.characterData = characterData
  }
}

// MARK: - RequestBuilder
extension DataManager {
  func requestBuilder(dataEndpoint: String, authModel: AuthModel, page: Int?) -> URLRequest? {
    let endpoint = "https://esi.evetech.net/latest"
    
    guard let accessTokenData = decodeAccessToken(data: authModel.accessToken) else {
      return nil
    }
    
    let characterEndpoint = "/characters/\(accessTokenData.characterID)/"
    
    let urlString = endpoint + characterEndpoint + dataEndpoint
    let url = URL(string: urlString)!
    var url1 = URLComponents(string: urlString)!
    
    if let page = page {
      url1.queryItems = APIHelper.mapValuesToQueryItems([
        "page": page
      ])
    }
    
    var urlRequest = URLRequest(url: url1.url!)
    
    let headers: [String:String] = [
      "Authorization": "Bearer \(authModel.accessToken)"
    ]
    
    urlRequest.allHTTPHeaderFields = headers
    return urlRequest
  }
  
  func decodeAccessToken(data: String) -> AccessTokenData? {
    let decoder = JSONDecoder()
    let response = decode(jwtToken: data)
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
      return try decoder.decode(AccessTokenData.self, from: jsonData)
    } catch let err {
      print("decode error \(err)")
      return nil
    }
  }
}

// Group stuff
extension DataManager {
  func fetchGroupInfoFor(groupId: Int32) {
    print("fetchGroupInfoFor()")
    
    let endpoint = "universe/groups/\(groupId)/"
    //DispatchQueue.main.async {
    //}
    
  }
  
  func fetchGroupInfoFor(groupIds: [Int32]) {
    
  }
}


extension DataManager {
  func fetchTypeInfoFor(typeId: Int32) {
    print("fetchTypeInfoFor()")
    let endpoint = "universe/types/\(typeId)/"
  }
}

// MARK: - Assets
extension DataManager {
  
  func fetchAssets(mocked: Bool = false) {
    print("fetchAssets()")
    guard !mocked else {
      makeMockAssets()
      return
    }
    guard let dbManager = dbManager else {
      return
    }
    
    
    Task {
      let characters = try await dbManager.getCharacters()
      
//      guard characters.count > 0,
//            let characterData = dbManager.getCharacter(by: characters[0].characterId) else {
//        return
//      }
      if let (data, response) = await makeApiCallAsync1(dataEndpoint: "assets/") {
        do {
          let string1 = String(data: data, encoding: .utf8)
          print("assets response got \(string1)")
          let characterAssetData = try JSONDecoder()
            .decode([GetCharactersCharacterIdAssets200Ok].self, from: data)
         //print("got json data \(characterAssetData)")
          
//          self.processCharacterAssetData(response: characterAssetData, characterId: characterData.characterID)
          
        } catch let err {
          print("got err \(err)")
        }
      }
    }
  }
  
  func processCharacterAssetData(response: [GetCharactersCharacterIdAssets200Ok], characterId: String) {
    print("processCharacterAssetData() for \(characterId) \(response.count)")
    Task {
      do {
          guard let characterAssetModel = await dbManager?.getCharacter(by: characterId) else {
            print("NO CHARACTER DATA MODEL FOR \(characterId)")
            return
          }
          // TODO: MOVE TO DB MANAGER
        let responseModels = response.map { CharacterAssetsDataModel(data: $0)}
        try await characterAssetModel.$assetsData.create(responseModels, on: dbManager!.database)
    
        
      } catch let err {
        print("processCharacterAssetData() - error: \(err)")
      }
    }
    
  }
  
  func makeMockAssets() {
    let foo =  GetCharactersCharacterIdAssets200Ok(
      isSingleton: false,
      itemId: 1003594322845,
      locationFlag: .hangar,
      locationId: 60011734,
      locationType: .station,
      quantity: 11,
      typeId: 2488
    )
    
    let foo1 =  GetCharactersCharacterIdAssets200Ok(
      isSingleton: false,
      itemId: 1045138627336,
      locationFlag: .hangar,
      locationId: 60011866,
      locationType: .station,
      quantity: 1,
      typeId: 33076
    )
    
    let characterData = self.characterData
    characterData?.assets = [foo, foo1]
    self.characterData = characterData
  }
  
}


