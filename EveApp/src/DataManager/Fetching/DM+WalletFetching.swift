//
//  DM+WalletFetching.swift
//  EveApp
//
//  Created by Erik Hatfield on 1/21/25.
//


import Foundation
import Fluent
import FluentSQLiteDriver
import ModelLibrary

// MARK: - Wallet

extension DataManager {
  
  func updateAllCharacterWallets() async {
    guard let characters = await dbManager?.getCharacters() else {
      print("Got no characters")
      return
    }
    await withTaskGroup(of: Void.self) { taskgroup in
      for character in characters {
        taskgroup.addTask {
          await self.updateCharacterWallet(character)
        }
      }
    }
  }
  
  func updateCharacterWallet(characterId: String) async {
    print("updateCharacterWallet(\(characterId))")
    guard let characterModel = await dbManager?.getCharacterWithInfo(by: characterId) else {
      print("no characterModel for \(characterId)")
      return
    }
    
    await updateCharacterWallet(characterModel)
  }
  
  func updateCharacterWallet(_ character: CharacterDataModel) async {
    print("updateCharacterWallet \(character.characterId)")
    guard let authModel = await dbManager?.getAuthModel(for: character.characterId) else {
      print("No authModel for \(character.characterId)")
      return
    }

    let characterId = character.characterId
    var walletModel = CharacterWalletModel()
    let existingWalletModel = character.$walletData.value ?? nil
    
    if let existingWalletModel {
      walletModel = existingWalletModel
    } else {
      do {
        try await character.$walletData.create(walletModel, on: dbManager!.database)
      } catch let err {
        print("write object error \(err)")
      }
    }

    if let characterWalletBalance = await getCharacterWalletBalance(characterID: characterId, authModel: authModel) {
      print("characterWalletBalance \(characterWalletBalance)")
      walletModel.balance = characterWalletBalance
      do {
        try await walletModel.update(on: dbManager!.database)
        print("updated \(walletModel.id) to \(walletModel.balance)")
      } catch let err {
        print("write wallet model error \(err)")
      }
      
    }
    
    if let characterWalletJournal = await getCharacterWalletJournal(characterID: characterId, authModel: authModel) {
      print("CharacterWalletJournal \(characterWalletJournal.count)")
      let walletEntries = characterWalletJournal.map { entry in
        return CharacterWalletJournalEntryModel(data: entry)
      }
      do {
        print("wallet \(walletModel.id)")
        // this will need to be done better
        try await walletModel.$journalEntries
          .create(
            walletEntries,
            on: dbManager!.database
          )
      } catch let err {
        print("write journal object error \(err)")
      }
    }
    
    if let characterWalletTransactions = await getCharacterWalletTransactions(characterID: characterId, authModel: authModel) {
      print("CharacterWalletTransactions \(characterWalletTransactions.count)")
      let walletTransactions = characterWalletTransactions.map { CharacterWalletTransactionModel(data: $0) }
      do {
        // this will need to be done better
        try await walletModel.$transactions.create(walletTransactions, on: dbManager!.database)
      } catch let err {
        print("write transaction object error \(err)")
      }
    }
    
  }
  
  func updateCharacterWalletBalance(characterId: String) async {
    print("updateCharacterWalletBalance(\(characterId))")
    guard let characterModel = await dbManager?.getCharacterWithInfo(by: characterId) else {
      print("no characterModel for \(characterId)")
      return
    }
    
    await updateCharacterWalletBalance(characterModel)
  }
  
  func updateCharacterWalletBalance(_ character: CharacterDataModel) async {
    print("updateCharacterWalletBalance \(character.characterId)")
    guard let authModel = await dbManager?.getAuthModel(for: character.characterId) else {
      print("No authModel for \(character.characterId)")
      return
    }

    let characterId = character.characterId
    var walletModel = CharacterWalletModel()
    let existingWalletModel = character.$walletData.value ?? nil
    
    if let existingWalletModel {
      walletModel = existingWalletModel
    } else {
      do {
        try await character.$walletData.create(walletModel, on: dbManager!.database)
      } catch let err {
        print("write object error \(err)")
      }
    }

    if let characterWalletBalance = await getCharacterWalletBalance(characterID: characterId, authModel: authModel) {
      print("characterWalletBalance \(characterWalletBalance)")
      walletModel.balance = characterWalletBalance
      do {
        try await walletModel.update(on: dbManager!.database)
        print("updated \(walletModel.id) to \(walletModel.balance)")
      } catch let err {
        print("write wallet model error \(err)")
      }
      
    }
  }
  
  func updateCharacterWalletJournal(characterId: String) async {
    print("updateCharacterWalletJournal(\(characterId))")
    guard let characterModel = await dbManager?.getCharacterWithInfo(by: characterId) else {
      print("no characterModel for \(characterId)")
      return
    }
    
    await updateCharacterWalletJournal(characterModel)
  }
  
  func updateCharacterWalletJournal(_ character: CharacterDataModel) async {
    print("updateCharacterWalleJournal \(character.characterId)")
    
    guard let authModel = await dbManager?.getAuthModel(for: character.characterId) else {
      print("No authModel for \(character.characterId)")
      return
    }

    let characterId = character.characterId
    var walletModel = CharacterWalletModel()
    let existingWalletModel = character.$walletData.value ?? nil
    
    if let existingWalletModel {
      walletModel = existingWalletModel
    } else {
      do {
        print("create wallet data +")
        try await character.$walletData.create(walletModel, on: dbManager!.database)
      } catch let err {
        print("write object error \(err)")
      }
    }
    
    if let characterWalletJournal = await getCharacterWalletJournal(
        characterID: characterId,
        authModel: authModel
    ) {
      print("CharacterWalletJournal \(characterWalletJournal.count)")
      let walletEntries = characterWalletJournal.map { entry in
        return CharacterWalletJournalEntryModel(data: entry)
      }
      do {
        let startDates = characterWalletJournal.map { $0.date }
        let madeDates = walletEntries.map { $0.date }
        print("Start dates \(startDates)")
        print("wallet \(walletModel.id)")
        let journalIds = walletEntries.map { $0.id }
        print("journalIds \(journalIds)")
        // this will need to be done better
        await processWalletJournalEntries(walletEntries)
        try await walletModel.$journalEntries.create(walletEntries, on: dbManager!.database)
        
        
      } catch let err {
        print("write journal object error \(err)")
      }
    }

  }
  
  func updateCharacterWalletTransactions(characterId: String) async {
    print("updateCharacterWalletTransactions(\(characterId))")
    guard let characterModel = await dbManager?.getCharacterWithInfo(by: characterId) else {
      print("no characterModel for \(characterId)")
      return
    }
    
    await updateCharacterWalletTransactions(characterModel)
  }
  
  func updateCharacterWalletTransactions(_ character: CharacterDataModel) async {
    print("updateCharacterWalleTransactions \(character.characterId)")
    
    guard let authModel = await dbManager?.getAuthModel(for: character.characterId) else {
      print("No authModel for \(character.characterId)")
      return
    }

    let characterId = character.characterId
    var walletModel = CharacterWalletModel()
    let existingWalletModel = character.$walletData.value ?? nil
    
    if let existingWalletModel {
      walletModel = existingWalletModel
    } else {
      do {
        print("create wallet data ++")
        try await character.$walletData.create(walletModel, on: dbManager!.database)
      } catch let err {
        print("write object error \(err)")
      }
    }
    
    if let characterWalletTransactions = await getCharacterWalletTransactions(
      characterID: characterId,
      authModel: authModel
    ) {
      let dates = characterWalletTransactions.map { $0.date }
      print("got dates \(dates  )")
      print("CharacterWalletTransactions \(characterWalletTransactions.count)")
      let walletTransactions = characterWalletTransactions.map { CharacterWalletTransactionModel(data: $0) }
      let newDates = walletTransactions.map { $0.date }
      print("made dates \(newDates)")
      do {
        // this will need to be done better
        try await walletModel.$transactions
          .create(
            walletTransactions,
            on: dbManager!.database
          )
        print("created \(walletTransactions.count)")
      } catch let err {
        print("write transaction object error \(err)")
      }
    }
    
  }
  
  func getCharacterWalletBalance(characterID: String, authModel: AuthModel) async -> Double? {
    let dataEndpoint = "/characters/\(characterID)/wallet/"
    
    guard let (data, _) = await makeApiCallAsync3(
      dataEndpoint: dataEndpoint,
      authModel: authModel
    ) else {
      return nil
    }
    do {
      return try JSONDecoder().decode(Double.self, from: data)
    } catch let err {
      print("decode wallet balance error \(err)")
      return nil
    }
    
  }
  
  func getCharacterWalletJournal(
    characterID: String,
    authModel: AuthModel
  ) async -> [GetCharactersCharacterIdWalletJournal]? {
    let dataEndpoint = "/characters/\(characterID)/wallet/journal/"
    
    guard let (data, _) = await makeApiCallAsync3(
      dataEndpoint: dataEndpoint,
      authModel: authModel
    ) else {
      return nil
    }
    
    do {
      return try JSONDecoder().decode([GetCharactersCharacterIdWalletJournal].self, from: data)
    } catch let error {
      print("getCharacterWalletJournal error \(error)")
      return nil
    }
  }
  
  func getCharacterWalletTransactions(
    characterID: String,
    authModel: AuthModel
  ) async -> [GetCharactersCharacterIdWalletTransactions200Ok]? {
    let dataEndpoint = "/characters/\(characterID)/wallet/transactions/"
    
    guard let (data, _) = await makeApiCallAsync3(
      dataEndpoint: dataEndpoint,
      authModel: authModel
    ) else {
      return nil
    }
    
    do {
      
      return try JSONDecoder().decode([GetCharactersCharacterIdWalletTransactions200Ok].self, from: data)
    } catch let err {
      print("getCharacterWalletTransactions - error \(err)")
      return nil
    }
  }
}

