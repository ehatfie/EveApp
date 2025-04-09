//
//  DataManager+killmails.swift
//  EveApp
//
//  Created by Erik Hatfield on 4/4/25.
//
import ModelLibrary
import SwiftEveAuth
import Fluent

extension DataManager {
    func verifyCharacter(characterName: String) async -> Bool {
        return await dbManager?.getCharacterIdentifiersModel(named: characterName) != nil
    }
    
    func loadCharacterInfo(for characterIds: [Int64]) async {
        let characterPublicData = await fetchCharacterInfos(for: characterIds)
        
        let characterIdentifierModels = characterPublicData.map { characterId, publicDataResponse in
            CharacterIdentifiersModel(characterId: characterId, data: publicDataResponse)
        }
        do {
            try await characterIdentifierModels.create(on: dbManager!.database)
        } catch let error {
            print("Create CharacterIdentifierModel error: \(String(reflecting: error))")
        }
    }
}
