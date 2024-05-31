//
//  DBManager+Auth.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/26/24.
//


import Foundation
import SwiftUI

import NIO
import Fluent


// MARK: - Auth

extension DBManager {
  func updateAccessToken(response: AccessTokenResponse, accessTokenData: AccessTokenData) async {
    do {
      if let existing = try? await AuthModel
        .query(on: self.database)
        .filter(\.$characterId == accessTokenData.characterID)
        .first() {
        log("updateAccessToken(): updating existing AuthModel")
        
        existing.accessToken = response.access_token
        existing.expiration = Int64(Date().timeIntervalSinceReferenceDate) + Int64(response.expires_in)
        
        try await existing.save(on: self.database)
      } else {
        log("updateAccessToken(): create AuthModel")
        try await AuthModel(
          characterId: accessTokenData.characterID,
          response: response
        ).create(on: database)
      }
    } catch let error {
      log("updateAccessToken(): error \(error)")
    }
  }
  
  func getAuthModel(for characterId: String) async -> AuthModel? {
    return try? await AuthModel.query(on: database).filter(\.$characterId == characterId).first()
  }
}

// MARK: - CharacterData

extension DBManager {
  
  func createCharacterData(accessTokenData: AccessTokenData) async {
    do {
      guard  try await CharacterDataModel
        .query(on: self.database)
        .filter(\.$characterId == accessTokenData.characterID)
        .first() == nil else {
        return
      }
      log("createCharacterData(): creating for \(accessTokenData.characterID)")
      
      try await CharacterDataModel(characterID: accessTokenData.characterID)
        .create(on: self.database)
    } catch let error {
      log("createCharacterData(): error \(error)")
    }
  }
  
}
