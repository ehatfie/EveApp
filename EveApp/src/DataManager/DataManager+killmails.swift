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
            
            let attackers = data.package.killmail.attackers.map { ESIKmAttackerModel(killmailId: killmailId, data: $0)}
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
