//
//  DM+Fetching.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/26/24.
//

import Foundation
import Fluent
import FluentSQLiteDriver

// MARK: - Assets
extension DataManager {
  func fetchAssetsAsync(mocked: Bool = false) async {
    print("fetchAssets()")
    guard !mocked else {
      makeMockAssets()
      return
    }
    
    guard let dbManager = dbManager else {
      return
    }
    
    let characters = await dbManager.getCharacters()
    
    await withTaskGroup(of: Void.self) { group in
      for character in characters {
        group.addTask {
          await self.fetchAssetsAsync(for: character)
        }
      }
    }
  }
  
  func fetchAssetsAsync(for character: CharacterDataModel) async {
    guard let authModel = await dbManager?.getAuthModel(for: character.characterId) else {
      return
    }
    let values = await fetchAllAssets(authModel: authModel, page: 1)
    print("got values \(values.count)")
    let responseModels = values.map { CharacterAssetsDataModel(data: $0)}
    do {
      try await updateAssets(characterModel: character, assets: responseModels)
    } catch let err {
      print("update assets error \(err)")
    }
   
    print("fetchAssetsAsync - done")
  }
      
  func updateAssets(characterModel: CharacterDataModel, assets: [CharacterAssetsDataModel]) async throws {
    print("DM - updateAssets() for characterId: \(characterModel.characterId) \(assets.count) assets")
    let database = dbManager!.database
    try await deleteAssets(characterModel: characterModel)
    // create new asset entries
    try await characterModel.$assetsData.create(assets, on: database)
    print("DM - updateAssets(): saved \(assets.count) assets")
    // this could be done as delete all non matching, update matching, add new
  }
  
  func deleteAssets(characterModel: CharacterDataModel) async throws {
    print("DM - deletessets() for characterId: \(characterModel.characterId)")
    let database = dbManager!.database
    let existingAssets = try await characterModel.$assetsData.get(on: database).get()
    print("DM - delteAssets() deleting \(existingAssets.count)")
    // delete existing asset entries
    await withTaskGroup(of: Void.self) { group in
      for assets in existingAssets {
        group.addTask {
          try? await assets.delete(on: database)
        }
      }
    }
    print("DM - delteAssets() done")
  }
  
  func fetchAllAssets(authModel: AuthModel, page: Int) async -> [GetCharactersCharacterIdAssets200Ok] {
    print("IR: page\(page)")
    guard let (data, response) = await makeApiCallAsync(
      dataEndpoint: "assets/",
      authModel: authModel,
      page: page
    ) else {
      return []
    }
    do {
      let string1 = String(data: data, encoding: .utf8)
      print("assets response got \(string1)")
      let characterAssetData = try JSONDecoder()
        .decode([GetCharactersCharacterIdAssets200Ok].self, from: data)
      if characterAssetData.count > 0 {
        let nextData = await fetchAllAssets(authModel: authModel, page: page + 1)
        return characterAssetData + nextData
      }
      
    } catch let err {
      print("DM - fetchAssetsAsync1(): error \(err)")
    }
    
    return []
  }
  
}

// MARK: - Public Data

extension DataManager {
  func fetchCharacterInfoAsync() async throws {
    print("fetchCharacterInfoAsync()")
    let characters = await dbManager!.getCharacters()
    try await fetchPublicData(for: characters[0])
  }
  
  func fetchPublicData(for character: CharacterDataModel) async throws {
    print("fetchPublicData()")
    guard let authModel = await dbManager?.getAuthModel(for: character.characterId) else {
      return
    }
    
    guard let (data, response) = await makeApiCallAsync(
      dataEndpoint: "",
      authModel: authModel
    ) else {
      return
    }
    do {
      let characterPublicData = try JSONDecoder()
        .decode(CharacterPublicDataResponse.self, from: data)
      print("got character public data \(characterPublicData)")
    } catch let err {
      print("error \(err)")
    }
   
    
  }
}



extension DataManager {
  
}
