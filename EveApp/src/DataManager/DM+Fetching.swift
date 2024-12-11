//
//  DM+Fetching.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/26/24.
//

import Foundation
import Fluent
import FluentSQLiteDriver
import ModelLibrary
//import TestPackage1



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
    guard let (data, _) = await makeApiCallAsync(
      dataEndpoint: "assets/",
      authModel: authModel,
      page: page
    ) else {
      return []
    }
    do {
      let string1 = String(data: data, encoding: .utf8)
      print("assets response got \(String(describing: string1))")
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
    
    guard let (data, _) = await makeApiCallAsync(
      dataEndpoint: "",
      authModel: authModel
    ) else {
      return
    }
    do {
      let characterPublicDataResponse = try JSONDecoder()
        .decode(CharacterPublicDataResponse.self, from: data)
      let publicDataModel = CharacterPublicDataModel(response: characterPublicDataResponse)
      
      try await character.$publicData.create(publicDataModel, on: dbManager!.database)
      print("got character public data \(characterPublicDataResponse)")
    } catch let err {
      print("error \(err)")
    }
  }
  
  func fetchCharacterIcons() async throws {
    let characters = await dbManager!.getCharacters()
    await withTaskGroup(of: Void.self) { taskGroup in
      characters.forEach { character in
        taskGroup.addTask {
          do {
            _ = try await self.fetchIcon(for: character)
          } catch let err {
            print("taskGroup erro \(err)")
          }
        }
      }
    }
  }
  
  func fetchIcon(for character: CharacterDataModel) async throws -> GetCharactersCharacterIdPortraitOk?  {
    guard let authModel = await dbManager?.getAuthModel(for: character.characterId) else {
      return nil
    }
    
    guard let (data, _) = await makeApiCallAsync3(
      dataEndpoint: "/characters/\(authModel.characterId)/portrait/",
      authModel: authModel
    ) else {
      return nil
    }
    
    do {
      let string1 = String(data: data, encoding: .utf8)
      print("fetchIconResponse got \(string1)")
      
      let portraitResponse = try JSONDecoder()
        .decode(GetCharactersCharacterIdPortraitOk.self, from: data)
      return portraitResponse
      print("got characterPortrait response \(portraitResponse.px128x128)")
    } catch let err {
      print("fetchIcon error \(err)")
      print("")
      return nil
    }
  }
  
  func fetchCharacterInfos(for characterIds: [Int64]) async
  -> [(Int64, CharacterPublicDataResponse)] {
    guard let authModel = await getAuthModel() else { return  []}
    
    let results = await withTaskGroup(
      of: (Int64, CharacterPublicDataResponse?).self,
      returning: [(Int64, CharacterPublicDataResponse)].self
    ) { taskGroup in
        
      for characterId in characterIds {
        taskGroup.addTask {
          let characterInfo =  await self.fetchCharacterInfo(
            for: characterId,
            authModel
          )
          
          return (characterId, characterInfo)
        }
      }
      
      var returnValues = [(Int64, CharacterPublicDataResponse)]()
      
      for await response in taskGroup {
        guard let responseData = response.1 else { continue }
        
        returnValues.append((response.0, responseData))
      }
      return returnValues
    }
    
    return results
    //let foo = fetchCharacterInfo(for: <#T##Int64#>, <#T##authModel: AuthModel##AuthModel#>)
    
  }
  
  func fetchCharacterInfo(
    for characterID: Int64,
    _ authModel: AuthModel
  ) async -> CharacterPublicDataResponse? {
    
    guard let (data, _) = await makeApiCallAsync3(
      dataEndpoint: "/characters/\(characterID)/",
      authModel: authModel
    ) else {
      return nil
    }
    
    do {
      let characterPublicDataResponse = try JSONDecoder()
        .decode(CharacterPublicDataResponse.self, from: data)
      //let publicDataModel = CharacterPublicDataModel(response: characterPublicDataResponse)
      
      //try await character.$publicData.create(publicDataModel, on: dbManager!.database)
      print("got character public data \(characterPublicDataResponse)")
      return characterPublicDataResponse
    } catch let err {
      print("error \(err)")
      return nil
    }
    
  }
}

// MARK: - Locations

extension DataManager {
  
  func getAuthModel() async -> AuthModel? {
    let characters = await dbManager!.getCharacters()
    
    guard let authModel = await dbManager!.getAuthModel(for: characters[0].characterId) else {
      print("fetchStructureId() - no auth model")
      return nil
    }
    
    return authModel
  }
  
  func fetchMultipleSolarSystemInfo(systemIds: [Int64]) async -> [GetUniverseSystemsSystemIdOk] {
    guard let authModel = await getAuthModel() else { return [] }
    let responseObjects = await withTaskGroup(
      of: GetUniverseSystemsSystemIdOk?.self,
      returning: [GetUniverseSystemsSystemIdOk].self
    ) { taskGroup in
        for systemId in systemIds {
        taskGroup.addTask {
          return await self.fetchSolarSystemInfo(systemId: systemId, authModel)
        }
      }
      var returnValues: [GetUniverseSystemsSystemIdOk] = []
      for await response in taskGroup {
        if let response = response {
          returnValues.append(response)
        }
      }
      return returnValues
    }
    
    return responseObjects
  }
  
  // GetUniverseSystemsSystemIdOk
  func fetchSolarSystemInfo(systemId: Int64, _ authModel: AuthModel) async -> GetUniverseSystemsSystemIdOk? {
    let dataEndpoint = "/universe/systems/\(systemId)/"
    
    guard let (data, _) = await makeApiCallAsync3(
      dataEndpoint: dataEndpoint,
      authModel: authModel
    ) else {
      return nil
    }
    let string1 = String(data: data, encoding: .utf8)
    print("fetchSolarSystemInfo() - got \(String(describing: string1))")
    
    do {
      let solarSystemInfo = try JSONDecoder()
        .decode(GetUniverseSystemsSystemIdOk.self, from: data)
      return solarSystemInfo
    } catch let err {
      print("fetch solar system info err \(err)")
      return nil
    }
  }
  
  func fetchLocations(assets: [CharacterAssetsDataModel]) async {
    var uniqueLocations = Set<Int64>()
    guard let valid = assets.first else {//(where: { $0.locationId > 100000000}) else {
      print("no valid station ID in \(assets.map{$0.locationId})")
      return
    }
    [assets[1]].forEach { uniqueLocations.insert($0.locationId)}
    
    await withTaskGroup(of: Void.self) { taskGroup in
      uniqueLocations.forEach { value in
        taskGroup.addTask {
          await self.fetchStructureId(structureId: value)
        }
      }
    }

  }
  
  func fetchLocation(asset: CharacterAssetsDataModel) async {
    let characters = await dbManager!.getCharacters()
    
  }
  
  func fetchStructureId(structureId: Int64) async {
    let characters = await dbManager!.getCharacters()
    guard characters.count > 0 else {
      print("no characters got")
      return
    }
    
    guard let authModel = await dbManager!.getAuthModel(for: characters[0].characterId) else {
      print("fetchStructureId() - no auth model")
      return
    }
    
    guard let (data, response) = await makeApiCallAsync3(
      dataEndpoint: "/universe/stations/\(structureId)/",
      authModel: authModel
    ) else {
      return
    }
    do {
      let string1 = String(data: data, encoding: .utf8)
      print("getStationIdResponse got \(string1)")
      
      let stationIdResponse = try JSONDecoder()
        .decode(GetStationInfoResponse.self, from: data)
      print("got stationIdResponse \(stationIdResponse.name)")
    } catch let err {
      print("fetchStructureId error \(err)")
      print("")
    }
  }
}

// MARK: - Api callers

extension DataManager {
  func makeApiCallAsync3(dataEndpoint: String, authModel: AuthModel, page: Int? = nil) async -> (Data, URLResponse)?  {
    let urlRequest = requestBuilder2(dataEndpoint: dataEndpoint, authModel: authModel, page: page)
    print("makeApiCallAsync3() - urlRequest \(urlRequest?.url?.string)")
    do {
      return try await URLSession.shared.data(for: urlRequest!)
    } catch let err {
      print("async api call error \(err)")
    }
    return nil
  }
  
  func requestBuilder2(dataEndpoint: String, authModel: AuthModel, page: Int?) -> URLRequest? {
    let endpoint = "https://esi.evetech.net/latest"
    
    guard let accessTokenData = decodeAccessToken(data: authModel.accessToken) else {
      return nil
    }
    
    let urlString = endpoint + dataEndpoint
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
}

// MARK: - Skills

extension DataManager {
  func fetchSkillsForCharacters() async {
    print("fetchSkillsForCharacters()")
    guard let characters = await dbManager?.getCharacters() else {
      return
    }
    
    await withTaskGroup(of: Void.self) { taskGroup in
      characters.forEach{ characterDataModel in
        taskGroup.addTask {
          await self.fetchSkillsForCharacter(characterModel: characterDataModel)
        }
      }
    }
  }
  
  func fetchSkillsForCharacter(characterModel: CharacterDataModel) async {
    guard let authModel = await dbManager?.getAuthModel(for: characterModel.characterId) else {
      return
    }
    
    guard let (data, response) = await makeApiCallAsync3(
      dataEndpoint: "/characters/\(characterModel.characterId)/skills",
      authModel: authModel
    ) else {
      return
    }
    let string1 = String(data: data, encoding: .utf8)
    print("fetch skills for character response got \(string1!)")
    do {
      let skills = try JSONDecoder().decode(GetCharactersCharacterIdSkillsOk.self, from: data)
      let skillsModels = CharacterSkillsDataModel(characterId: characterModel.characterId, data: skills)
      try await characterModel.$skillsData.create(skillsModels, on: dbManager!.database)
      print("got skills \(skills)")
      //await self.dbManager?.save(skills, for: characterModel)
    } catch {
      print("Error decoding skills: \(error)")
    }
  }
}

// MARK: - Corporation

extension DataManager {
  
  func fetchCorporationInfoForCharacters() async {
    print("fetcCorporationInfo()")
    guard let characters = await dbManager?.getCharacters() else {
      return
    }
    
    await withTaskGroup(of: Void.self) { taskGroup in
      characters.forEach { characterDataModel in
        taskGroup.addTask {
          await self.fetchCorporationInfoForCharacter(characterModel: characterDataModel)
        }
      }
    }
  }
  
  func fetchCorporationInfoForCharacter(characterModel: CharacterDataModel) async {
    guard let authModel = await dbManager?.getAuthModel(for: characterModel.characterId),
          let publicData = characterModel.publicData
    else {
      return
    }
    
    do {
      if let existingCorp = try await CorporationInfoModel
        .query(on: dbManager!.database)
        .filter(\.$corporationId == publicData.corporationId)
        .first() {
        print("found existing corp \(existingCorp.name)")
        try await characterModel.$corp
          .attach(
            [existingCorp],
            on: dbManager!.database
          )
        return
      }
    } catch let err {
      print("query error \(err)")
    }
    
    guard let (data, response) = await makeApiCallAsync3(
      dataEndpoint: "/corporations/\(publicData.corporationId)",
      authModel: authModel
    ) else {
      return
    }
    let string1 = String(data: data, encoding: .utf8)
    print("get corp info response got \(string1!)")
    do {
      let corpInfoResponse = try JSONDecoder()
        .decode(GetCorporationInfoResponse.self, from: data)
      print("got corpInfo \(corpInfoResponse.name)")
      
      let corpInfoModel = CorporationInfoModel(
        from: corpInfoResponse, 
        corporationId: publicData.corporationId
      )
      
      try await corpInfoModel.create(on: dbManager!.database)
      
      try await characterModel.$corp
        .attach(
          [corpInfoModel],
          on: dbManager!.database
        )
    } catch let err {
      print("error \(err)")
    }
  }
  
}

// MARK: - IndustryJobs

extension DataManager {
  func fetchIndustryJobsForCharacters() async {
    guard let characters = await dbManager?.getCharacters() else {
      return
    }
    
    await withTaskGroup(of: Void.self) { taskGroup in
      for character in characters {
        taskGroup.addTask {
          await self.fetchIndustryJobs(for: character)
        }
      }
    }
  }
  
  func fetchIndustryJobs(
    for characterModel: CharacterDataModel
  ) async {
    guard 
      let authModel = await dbManager?.getAuthModel(
        for: characterModel.characterId
      )
    else {
      return
    }
    
    let characterId = characterModel.characterId
    let dataEndpoint = "/characters/\(characterId)/industry/jobs/"
    
    guard let (data, _) = await makeApiCallAsync3(
      dataEndpoint: dataEndpoint,
      authModel: authModel
    ) else {
      return
    }
    
    let string1 = String(data: data, encoding: .utf8)
    print("get industry jobs response got \(string1!)")
    
    do {
      let industryJobsResponse = try JSONDecoder()
        .decode(
          [GetCharactersIndustryJobsResponse].self,
          from: data
        )
      
      let industryJobsModels = industryJobsResponse.map {
        CharacterIndustryJobModel(
          characterId: characterId,
          data: $0
        )
      }
      
      print("got industryJobsModel \(industryJobsModels.count)")
      
      let database = dbManager!.database
      try await characterModel.$industryJobsData
        .create(
          industryJobsModels,
          on: database
        )
    } catch let err {
      print("fetch industry jobs err \(err)")
    }
  }
}


