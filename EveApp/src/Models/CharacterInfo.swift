//
//  CharacterInfo.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/3/23.
//

import Foundation
import ModelLibrary
import TestPackage3

class CharacterInfo {
    let characterID: String
    var publicData: CharacterPublicDataResponse?
    var skillQueue: [CharacterSkillQueueDataResponse]?
    var assets: [GetCharactersCharacterIdAssets200Ok] = []
    
    init(
        characterID: String,
        publicData: CharacterPublicDataResponse? = nil,
        assets: [GetCharactersCharacterIdAssets200Ok] = []
    ){
        self.characterID = characterID
        self.publicData = publicData
        self.assets = assets
    }
}
