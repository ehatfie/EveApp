//
//  CharacterPublicData.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/3/23.
//

import Foundation

struct CharacterPublicDataResponse: Decodable {
    let alliance_id: Int32?
    let birthday: String // date-time
    let bloodline_id: Int32
    let corporation_id: Int32
    let description: String?
    let faction_id: Int32?
    let gender: String
    let name: String
    let race_id: Int32
    let security_status: Float?
    let title: String?
}
