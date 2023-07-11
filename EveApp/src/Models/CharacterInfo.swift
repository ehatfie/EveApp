//
//  CharacterInfo.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/3/23.
//

import Foundation

class CharacterInfo {
    let characterID: String
    var publicData: CharacterPublicDataResponse?
    var skillQueue: [CharacterSkillQueueDataResponse]?
    
    init(characterID: String, publicData: CharacterPublicDataResponse? = nil){
        self.characterID = characterID
        self.publicData = publicData
    }
}
