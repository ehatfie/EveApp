////
////  ZKillResponseData.swift
////  EveApp
////
////  Created by Erik Hatfield on 7/15/25.
////
import Foundation
import ModelLibrary

//public struct ZKillResponseData: Codable {
//  public let killmail_id: Int64
//  public let zkb: ZKillMailData
//}
//
//public struct ZKillMailData: Codable {
//  public let locationID: Int64
//  public let hash: String
//  public let fittedValue: Double
//  public let droppedValue: Double
//  public let destroyedValue: Double
//  public let totalValue: Double
//  public let points: Int
//  public let npc: Bool
//  public let solo: Bool
//  public let awox: Bool
//  public let labels: [String]
//}

public struct ZKillFeedResponseWrapper: Codable, Sendable {
  let package: ZKillFeedResponse
}

public struct ZKillFeedResponse: Codable, Sendable {
  let killID: Int64
  let killmail: EveKmData
}

//public struct EveKmData: Codable, Sendable {
//  public let attackers: [EveKmAttackerData]
//  public let killmail_id: Int64
//  public let killmail_time: String
//  public let moon_id: Int64?
//  public let solar_system_id: Int64
//  public let victim: EveKmVictimData
//  public let war_id: Int64?
//}
//
//public struct EveKmAttackerData: Codable, Sendable {
//  public let alliance_Id: Int64?
//  public let character_id: Int64?
//  public let corporation_id: Int64?
//  public let damage_done: Int64
//  public let faction_id: Int64?
//  public let final_blow: Bool
//  public let security_status: Float
//  public let ship_type_id: Int64?
//  public let weapon_type_id: Int64?
//}
//
//public struct EveKmVictimData: Codable, Sendable {
//  public let alliance_Id: Int64?
//  public let character_id: Int64?
//  public let corporation_id: Int64?
//  public let damage_taken: Int64
//  public let faction_id: Int64?
//  public let items: [EveKmVictimItemsData]?
//  public let position: EveKmVictimPositionData?
//  public let ship_type_id: Int64?
//}
//
//public struct EveKmVictimItemsData: Codable, Sendable {
//  public let flag: Int64
//  public let item_type_id: Int64
//  public let items: [EveKmVictimItemsData]?
//  public let quantity_destroyed: Int64?
//  public let quantity_dropped: Int64?
//  public let singleton: Int64
//}
//
//public struct EveKmVictimPositionData: Codable, Sendable {
//  public let x: Double
//  public let y: Double
//  public let z: Double
//}
//
//final class KillMail {
//  var killID: Int
//  var timestamp: Date
//  var victimName: String
//  var victimValue: Int
//  var attackerNames: [String]
//  var solarSystemID: Int
//  var shipType: String
//
//  init(
//    killID: Int,
//    timestamp: Date,
//    victimName: String,
//    victimValue: Int,
//    attackerNames: [String],
//    solarSystemID: Int,
//    shipType: String
//  ) {
//    self.killID = killID
//    self.timestamp = timestamp
//    self.victimName = victimName
//    self.victimValue = victimValue
//    self.attackerNames = attackerNames
//    self.solarSystemID = solarSystemID
//    self.shipType = shipType
//  }
//}
