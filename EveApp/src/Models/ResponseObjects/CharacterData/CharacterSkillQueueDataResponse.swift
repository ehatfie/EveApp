//
//  CharacterSkillQueueDataResponse.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/3/23.
//

import Foundation

struct CharacterSkillQueueDataResponse: Decodable, Identifiable {
    var id: String { "\(skill_id)" }
    
    let finish_date: String?
    let finished_level: Int32
    let level_end_sp: Int32?
    let level_start_sp: Int32?
    let queue_position: Int32
    let skill_id: Int32
    let start_date: String?
    let training_start_sp: Int32?
}
