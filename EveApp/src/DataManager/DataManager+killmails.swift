import Fluent
//
//  DataManager+killmails.swift
//  EveApp
//
//  Created by Erik Hatfield on 4/4/25.
//
import ModelLibrary
import SwiftEveAuth

extension DataManager {
  func verifyCharacter(characterName: String) async -> Bool {
    return await dbManager?.getCharacterIdentifiersModel(named: characterName)
      != nil
  }

  func loadCharacterInfo(for characterIds: [Int64]) async {
    let characterPublicData = await fetchCharacterInfos(for: characterIds)

    let characterIdentifierModels = characterPublicData.map {
      characterId,
      publicDataResponse in
      CharacterIdentifiersModel(
        characterId: characterId,
        data: publicDataResponse
      )
    }
    do {
      try await characterIdentifierModels.create(on: dbManager!.database)
    } catch let error {
      print(
        "Create CharacterIdentifierModel error: \(String(reflecting: error))"
      )
    }
  }

  func saveResponse(_ data: ZKillFeedResponseWrapper) {
    guard let dbManager else {
      return
    }
    //let model = ZKillmailModel(data: data.package.killmail)
    let model = ESIKillmailModel(data: data.package.killmail)
    //let models = data.map { ZKillmailModel(data: $0)}
    do {
      try model.create(on: dbManager.database).wait()
      let killmailId = model.killmailId

      let attackers = data.package.killmail.attackers.map {
        ESIKmAttackerModel(killmailId: killmailId, data: $0)
      }
      let victim = ESIKmVictimModel(data: data.package.killmail.victim)

      try model.$attackers.create(attackers, on: dbManager.database).wait()
      try model.$victim.create([victim], on: dbManager.database).wait()

      print("-- created model for \(data.package.killID)")
    } catch let err {
      print("-- error creating model \(String(reflecting: err))")
    }

  }

  func startListener() {
    Task {
      await self.redisActor.start()
    }
  }

  func stopListener() {
    Task {
      await self.redisActor.shutdown()
    }
  }
}

// MARK: - Killmail Processing

extension DataManager {
  func process(data: ZKillFeedResponseWrapper) async {
    /// We want to fetch any additional data here
    /// EX
    /// - Character Info
    /// - Corporation Info
    /// - Alliance Info
    /// - System Info

    let response = data.package

    let killID = response.killID
    let killmailObject = response.killmail

    async let characterProcessing: () = await processCharacterInfo(for: killmailObject)
    async let corporationProcessing: () = await processCorporationInfo(for: killmailObject)
    async let allianceProcessing: () = await processAllianceInfo(for: killmailObject)

    _ = await [characterProcessing, corporationProcessing]
    
    //await relateCharacterInfos(for: killmailObject)
  }

  func processCharacterInfo(for data: EveKmData) async {
    let attackers = data.attackers
    let victim = data.victim
    let attackerIds: [Int64] = attackers.compactMap { $0.character_id }
    var characterIds = attackerIds

    if let victimId = victim.character_id {
      characterIds.append(victimId)
    }

    let uniqueCharacterIds: Set<Int64> = Set<Int64>(characterIds)

    let characterIdentifierModels = await fetchCharacterInfos1(
      for: Array(uniqueCharacterIds)
    )
    let db = dbManager!.database
    do {
      try await characterIdentifierModels.create(on: db)
      
      print(
        "created \(characterIdentifierModels.count) CharacterIdentifierModels"
      )
    } catch let err {
      print("Save CharacterIdentifiersModels err \(err)")
    }
  }
  
  func processCorporationInfo(for data: EveKmData) async {
    let attackers = data.attackers
    let victim = data.victim
    
    let attackerCorporationIDs = attackers.compactMap({ $0.corporation_id })
    
    var corporationIds: Set<Int64> = Set<Int64>(attackerCorporationIDs)
    
    if let victimCorporationID = victim.corporation_id {
      corporationIds.insert(victimCorporationID)
    }
    
    let corporationInfoResponses = await fetchCorporationInfos1(for: Array(corporationIds))
    
    do {
      let corporationInfoModels = corporationInfoResponses.map { response in
        return CorporationInfoModel(from: response.1, corporationId: Int32(response.0))
      }
      try await corporationInfoModels.create(on: dbManager!.database)
      print("++ created \(corporationInfoModels.count) CorporationInfoModels")
    } catch let error {
      print("++ insert Error \(String(reflecting: error))")
    }
  }
  
  func processAllianceInfo(for data: EveKmData) async {
    let attackers = data.attackers
    let victim = data.victim
    
    let attackerAllianceIDs = attackers.compactMap({ $0.alliance_Id })
    
//    do {
//      let allianceInfoModels = corporationInfoResponses.map { response in
//        return CorporationInfoModel(from: response.1, corporationId: Int32(response.0))
//      }
//      try await corporationInfoModels.create(on: dbManager!.database)
//      print("++ created \(corporationInfoModels.count) CorporationInfoModels")
//    } catch let error {
//      print("++ insert Error \(String(reflecting: error))")
//    }
  }
  
  func relateCharacterInfo(for data: EveKmData) {
    
  }

  // TODO: Move to DBManager?
  func fetchCharacterInfos1(for characterIDs: [Int64]) async
    -> [CharacterIdentifiersModel]
  {
    let db = dbManager!.database
    let matchingCharacterIdentifiers =
      (try? await CharacterIdentifiersModel.query(on: db)
        .filter(\.$characterID ~~ characterIDs)
        .all()) ?? []

    let someIds: Set<Int64> = Set<Int64>(matchingCharacterIdentifiers.map { $0.characterID })
    
    let filteredNewIDs = characterIDs.filter({ !someIds.contains($0) })
    let results = await self.fetchCharacterInfos(
      for: filteredNewIDs
    )

    let characterIdentifierModels = results.map { id, response in
      return CharacterIdentifiersModel(
        characterId: id,
        data: response
      )
    }

    return characterIdentifierModels
  }
  
  func fetchCorporationInfos1(for corporationIDs: [Int64]) async -> [(Int64, GetCorporationInfoResponse)] {
    guard let authModel = await self.getAnyAuthModel() else {
      return []
    }
    
    let db = dbManager!.database
    let typedIds = corporationIDs.map { Int32($0)}
    let matchingCharacterIdentifiers = (try? await CorporationInfoModel.query(on: db)
      .filter(\.$corporationId ~~ typedIds)
      .all()) ?? []
    
    let existingCorporationIds: Set<Int64> = Set<Int64>(matchingCharacterIdentifiers.map { Int64($0.corporationId) })
    
    let filteredNewIds = corporationIDs.filter({ !existingCorporationIds.contains($0) })

    let results = await fetchCorporationInfoModels(for: filteredNewIds, authModel: authModel)
    return results
  }
}
