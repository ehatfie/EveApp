//
//  CharacterPublicData.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/3/23.
//

import Foundation

public struct CharacterPublicDataResponse: Decodable {
    public let alliance_id: Int32?
    public let birthday: String // date-time
    public let bloodline_id: Int32
    public let corporation_id: Int32
    public let description: String?
    public let faction_id: Int32?
    public let gender: String
    public let name: String
    public let race_id: Int32
    public let security_status: Float?
    public let title: String?
}
