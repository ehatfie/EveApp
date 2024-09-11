//
//  Zkill Response Objects.swift
//  TestPackage1
//
//  Created by Erik Hatfield on 9/10/24.
//

public struct ZKillResponseData: Codable {
    public let killmail_id: Int64
    public let zkb: ZKillMailData
}

public struct ZKillMailData: Codable {
    public let locationID: Int64
    public let hash: String
    public let fittedValue: Double
    public let droppedValue: Double
    public let destroyedValue: Double
    public let totalValue: Double
    public let points: Int
    public let npc: Bool
    public let solo: Bool
    public let awox: Bool
    public let labels: [String]
}

public struct EveKmData: Codable {
    public let attackers: [EveKmAttackerData]
    public let killmail_id: Int64
    public let killmail_time: String
    public let moon_id: Int64?
    public let solar_system_id: Int64
    public let victim: EveKmVictimData
    public let war_id: Int64?
}

public struct EveKmAttackerData: Codable {
    public let alliance_Id: Int64?
    public let character_id: Int64?
    public let corporation_id: Int64?
    public let damage_done: Int64
    public let faction_id: Int64?
    public let final_blow: Bool
    public let security_status: Float
    public let ship_type_id: Int64?
    public let weapon_type_id: Int64?
}

public struct EveKmVictimData: Codable {
    public let alliance_Id: Int64?
    public let character_id: Int64?
    public let corporation_id: Int64?
    public let damage_taken: Int64
    public let faction_id: Int64?
    public let items: [EveKmVictimItemsData]?
    public let position: EveKmVictimPositionData?
    public let ship_type_id: Int64?
}

public struct EveKmVictimItemsData: Codable {
    public let flag: Int64
    public let item_type_id: Int64
    public let items: [EveKmVictimItemsData]?
    public let quantity_destroyed: Int64?
    public let quantity_dropped: Int64?
    public let singleton: Int64
}

public struct EveKmVictimPositionData: Codable {
    public let x: Double
    public let y: Double
    public let z: Double
}


/*
 
 {
   "killmail_id": 120563569,
   "zkb": {
     "locationID": 40464335,
     "hash": "dda82e81ae96fa86142a14052c6c24d5d92564ca",
     "fittedValue": 2250300414.08,
     "droppedValue": 643877298.87,
     "destroyedValue": 1647626580.14,
     "totalValue": 2291503879.01,
     "points": 12,
     "npc": false,
     "solo": false,
     "awox": false,
     "labels": [
       "cat:6",
       "#:5+",
       "pvp",
       "loc:w-space",
       "isk:1b+"
     ]
   }
 }
 */

/*
 {
   "attackers": [
     {
       "character_id": 96837778,
       "corporation_id": 98545028,
       "damage_done": 42834,
       "final_blow": false,
       "security_status": -1.9,
       "ship_type_id": 28665,
       "weapon_type_id": 28665
     },
     {
       "character_id": 2120336885,
       "corporation_id": 98746441,
       "damage_done": 19904,
       "final_blow": true,
       "security_status": 3.7,
       "ship_type_id": 28661,
       "weapon_type_id": 3186
     },
     {
       "character_id": 210949499,
       "corporation_id": 98781943,
       "damage_done": 16184,
       "final_blow": false,
       "security_status": 4.7,
       "ship_type_id": 28659,
       "weapon_type_id": 28659
     },
     {
       "character_id": 2117416901,
       "corporation_id": 98781943,
       "damage_done": 8950,
       "final_blow": false,
       "security_status": 4.9,
       "ship_type_id": 28661,
       "weapon_type_id": 28661
     },
     {
       "character_id": 2120283726,
       "corporation_id": 98746441,
       "damage_done": 2462,
       "final_blow": false,
       "security_status": 3.2,
       "ship_type_id": 28665,
       "weapon_type_id": 31864
     }
   ],
   "killmail_id": 120563569,
   "killmail_time": "2024-08-31T17:48:52Z",
   "solar_system_id": 31002188,
   "victim": {
     "alliance_id": 99011603,
     "character_id": 2030637297,
     "corporation_id": 98454805,
     "damage_taken": 90334,
     "items": [
       {
         "flag": 5,
         "item_type_id": 30013,
         "quantity_destroyed": 16,
         "singleton": 0
       },
       {
         "flag": 12,
         "item_type_id": 13945,
         "quantity_destroyed": 1,
         "singleton": 0
       },
       {
         "flag": 21,
         "item_type_id": 2281,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 5,
         "item_type_id": 33474,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 5,
         "item_type_id": 56076,
         "quantity_destroyed": 1,
         "singleton": 0
       },
       {
         "flag": 29,
         "item_type_id": 12791,
         "quantity_destroyed": 37,
         "singleton": 0
       },
       {
         "flag": 5,
         "item_type_id": 45998,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 30,
         "item_type_id": 33400,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 33,
         "item_type_id": 12791,
         "quantity_destroyed": 37,
         "singleton": 0
       },
       {
         "flag": 11,
         "item_type_id": 2048,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 17,
         "item_type_id": 14230,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 22,
         "item_type_id": 41490,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 33,
         "item_type_id": 3186,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 15,
         "item_type_id": 1999,
         "quantity_destroyed": 1,
         "singleton": 0
       },
       {
         "flag": 31,
         "item_type_id": 3186,
         "quantity_destroyed": 1,
         "singleton": 0
       },
       {
         "flag": 5,
         "item_type_id": 21740,
         "quantity_destroyed": 1584,
         "singleton": 0
       },
       {
         "flag": 5,
         "item_type_id": 56068,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 14,
         "item_type_id": 13945,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 5,
         "item_type_id": 12787,
         "quantity_dropped": 2500,
         "singleton": 0
       },
       {
         "flag": 179,
         "item_type_id": 608,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 27,
         "item_type_id": 3186,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 23,
         "item_type_id": 20637,
         "quantity_destroyed": 1,
         "singleton": 0
       },
       {
         "flag": 32,
         "item_type_id": 12263,
         "quantity_destroyed": 1,
         "singleton": 0
       },
       {
         "flag": 28,
         "item_type_id": 12271,
         "quantity_destroyed": 1,
         "singleton": 0
       },
       {
         "flag": 16,
         "item_type_id": 1999,
         "quantity_destroyed": 1,
         "singleton": 0
       },
       {
         "flag": 93,
         "item_type_id": 26394,
         "quantity_destroyed": 1,
         "singleton": 0
       },
       {
         "flag": 5,
         "item_type_id": 12791,
         "quantity_destroyed": 3064,
         "singleton": 0
       },
       {
         "flag": 5,
         "item_type_id": 17938,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 20,
         "item_type_id": 19208,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 5,
         "item_type_id": 46002,
         "quantity_dropped": 2,
         "singleton": 0
       },
       {
         "flag": 31,
         "item_type_id": 12791,
         "quantity_destroyed": 37,
         "singleton": 0
       },
       {
         "flag": 5,
         "item_type_id": 28668,
         "quantity_destroyed": 300,
         "singleton": 0
       },
       {
         "flag": 13,
         "item_type_id": 13945,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 92,
         "item_type_id": 26086,
         "quantity_destroyed": 1,
         "singleton": 0
       },
       {
         "flag": 87,
         "item_type_id": 23705,
         "quantity_destroyed": 5,
         "singleton": 0
       },
       {
         "flag": 22,
         "item_type_id": 3578,
         "quantity_destroyed": 1,
         "singleton": 0
       },
       {
         "flag": 29,
         "item_type_id": 3186,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 19,
         "item_type_id": 35662,
         "quantity_dropped": 1,
         "singleton": 0
       },
       {
         "flag": 27,
         "item_type_id": 12791,
         "quantity_dropped": 37,
         "singleton": 0
       },
       {
         "flag": 5,
         "item_type_id": 41490,
         "quantity_destroyed": 6,
         "singleton": 0
       },
       {
         "flag": 87,
         "item_type_id": 2488,
         "quantity_destroyed": 5,
         "singleton": 0
       }
     ],
     "position": {
       "x": 126683307477.94453,
       "y": 1530870845.1478722,
       "z": 43264290532.30265
     },
     "ship_type_id": 28661
   }
 }
 */
