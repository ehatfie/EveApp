//
//  CharacterSkillQueueDataResponse.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/3/23.
//

import Foundation

public struct CharacterSkillQueueDataResponse: Decodable, Identifiable {
    public var id: String { "\(skill_id)" }
    
    public let finish_date: String?
    public let finished_level: Int32
    public let level_end_sp: Int32?
    public let level_start_sp: Int32?
    public let queue_position: Int32
    public let skill_id: Int32
    public let start_date: String?
    public let training_start_sp: Int32?
}
