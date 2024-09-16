//
//  DM+LocationFetching.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/2/24.
//

import Foundation
import ModelLibrary

// MARK: - Killmail

extension DataManager {
  func fetchKillmailInfo(killmailId: Int64, killmailHash: String) async -> EveKmData? {
    guard let characterModel = await dbManager?.getCharacters().first else {
      return nil
    }
    
    guard let authModel = await dbManager?.getAuthModel(
        for: characterModel.characterId
      )
    else {
      return nil
    }
    
    let dataEndpoint = "/killmails/\(killmailId)/\(killmailHash)/"
    
    guard let (data, _) = await makeApiCallAsync3(
      dataEndpoint: dataEndpoint,
      authModel: authModel
    ) else {
      return nil
    }
    
    let decoder = JSONDecoder()
      let foo = String(base64Encoding: data)
      
    do {
        let object = try decoder.decode(EveKmData.self, from: data)
        return object
        print("got object \(object)")
    } catch let err {
        print("decode errr \(err)")
        return nil
    }
  }
}
