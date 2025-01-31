//
//  DM+Processing.swift
//  EveApp
//
//  Created by Erik Hatfield on 1/21/25.
//

import Foundation
import Fluent
import FluentSQLiteDriver
import ModelLibrary

typealias ContextIdType = GetCharactersCharacterIdWalletJournal.ContextIdType
typealias RefType = GetCharactersCharacterIdWalletJournal.RefType

// MARK: - Wallet processing

extension DataManager {
  // Post processing for character wallet journal entries. Fetches missing character info etc
  func processWalletJournalEntries(
      _ entries: [CharacterWalletJournalEntryModel]
  ) async {
    print()
    print("processWalletJournalEntries()")
    print()
    var characterIds: Set<Int64> = []
    var systemIds: Set<Int64> = []
    
    for entry in entries {
      let refType = entry.refType
      guard let refTypeEnum = RefType(rawValue: refType) else { continue }
      
      //print("got refTypeEnum \(refTypeEnum)")
      switch refTypeEnum {
      case .playerTrading, .playerDonation, .marketEscrow, .marketTransaction:
        if let contextId = entry.contextId {
          // ignore for context id 0 and 1. 0 means money out 1 means money in. 0 wont have a contextIdType
          guard contextId != 0 && contextId != 1 else { continue }
        }
        guard let firstPartyId = entry.firstPartyId,
              let secondPartyId = entry.secondPartyId else { continue }
        characterIds.insert(Int64(firstPartyId))
        characterIds.insert(Int64(secondPartyId))
      
      default: break
      }
      
      
      if let contextIdType = entry.contextIdType,
        let contextEnum = ContextIdType(rawValue: contextIdType),
        let contextId = entry.contextId {
        switch contextEnum {
        case .characterId:
          guard let firstPartyId = entry.firstPartyId,
                let secondPartyId = entry.secondPartyId else { continue }
          print("fetch character ID for \(firstPartyId)")
        case .eveSystem:
          //print("fetch")
          systemIds.insert(contextId)
        default:
          break
        }
      }
    }
    
    do {
      //try await fetchAndUpdateSystems(for: systemIds)
      try await fetchAndUpdateCharacterPublicData(for: characterIds)
    } catch let err {
      print("create character model error \(err)")
    }

  }
  
  func fetchAndUpdateSystems(for systemIds: Set<Int64>) async throws {
    print("fetch and update systems")
    var systemIds = systemIds
    
    let systemModels = try await SolarSystemModel.query(on: self.dbManager!.database)
      .all()
      .get()
    
    let existingSystemIds = Set<Int64>(systemModels.map { $0.systemID })
    
    let systemIdsToFetch: Set<Int64> = systemIds.subtracting(existingSystemIds)
    print("fetching \(systemIdsToFetch.count) systems")
    
    guard let authModel = await dbManager?.getAnyAuthModel() else { return }
    
    var fetchedSystems: [SolarSystemModel] = []
    for systemId in systemIdsToFetch {
      guard let systemInfo = await fetchSolarSystemInfo(systemId: systemId, authModel) else {
        continue
      }
      let systemModel = SolarSystemModel(data: systemInfo)
      fetchedSystems.append(systemModel)
    }
    
    try await fetchedSystems.create(on: self.dbManager!.database)
  }
  
  func fetchAndUpdateCharacterPublicData(for characterIds: Set<Int64>) async throws {
    print("fetchAndUpdateCharacters")
    //var characterIds = characterIds
    let characterPublicData = try await CharacterPublicDataModel.query(on: dbManager!.database)
      .all()
      //.filter { $0.$publicData.value == nil}
    print("got characterModels \(characterPublicData.count)")
    
    let existingCharacterIds = Set<Int64>(
      characterPublicData
        .compactMap { Int64($0.characterId) }
    )
    print("original characterIds \(characterIds)")
    print("existing character Ids \(existingCharacterIds)")
    let characterIdsToFetch: Set<Int64> = characterIds.subtracting(existingCharacterIds)
    print("fetching characterIds \(characterIdsToFetch)")

//    let newCharacterModels = characterIdsToFetch.map { CharacterDataModel(characterID: String($0)) }
//    try await newCharacterModels.create(on: dbManager!.database).get()
//    print("created \(newCharacterModels.count) new CharacterDataModels")
    
    for characterId in characterIdsToFetch {
      try await self.updateCharacterPublicData(for: characterId)
    }
  }
}
