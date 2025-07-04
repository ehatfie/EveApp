//
//  GetStationInfoResponse.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/2/24.
//

import Foundation


/** 200 ok object */

public struct GetStationInfoResponse: Codable {

    public enum Services: String, Codable {
        case bountyMissions = "bounty-missions"
        case assasinationMissions = "assasination-missions"
        case courierMissions = "courier-missions"
        case interbus = "interbus"
        case reprocessingPlant = "reprocessing-plant"
        case refinery = "refinery"
        case market = "market"
        case blackMarket = "black-market"
        case stockExchange = "stock-exchange"
        case cloning = "cloning"
        case surgery = "surgery"
        case dnaTherapy = "dna-therapy"
        case repairFacilities = "repair-facilities"
        case factory = "factory"
        case labratory = "labratory"
        case gambling = "gambling"
        case fitting = "fitting"
        case paintshop = "paintshop"
        case news = "news"
        case storage = "storage"
        case insurance = "insurance"
        case docking = "docking"
        case officeRental = "office-rental"
        case jumpCloneFacility = "jump-clone-facility"
        case loyaltyPointStore = "loyalty-point-store"
        case navyOffices = "navy-offices"
        case securityOffices = "security-offices"
    }
    /** max_dockable_ship_volume number */
    public var maxDockableShipVolume: Float
    /** name string */
    public var name: String
    /** office_rental_cost number */
    public var officeRentalCost: Float
    /** ID of the corporation that controls this station */
    public var owner: Int?
    public var position: GetUniverseStationsStationIdPosition
    /** race_id integer */
    public var raceId: Int?
    /** reprocessing_efficiency number */
    public var reprocessingEfficiency: Float
    /** reprocessing_stations_take number */
    public var reprocessingStationsTake: Float
    /** services array */
    public var services: [Services]
    /** station_id integer */
    public var stationId: Int64
    /** The solar system this station is in */
    public var systemId: Int
    /** type_id integer */
    public var typeId: Int

    public init(maxDockableShipVolume: Float, name: String, officeRentalCost: Float, owner: Int? = nil, position: GetUniverseStationsStationIdPosition, raceId: Int? = nil, reprocessingEfficiency: Float, reprocessingStationsTake: Float, services: [Services], stationId: Int64, systemId: Int, typeId: Int) {
        self.maxDockableShipVolume = maxDockableShipVolume
        self.name = name
        self.officeRentalCost = officeRentalCost
        self.owner = owner
        self.position = position
        self.raceId = raceId
        self.reprocessingEfficiency = reprocessingEfficiency
        self.reprocessingStationsTake = reprocessingStationsTake
        self.services = services
        self.stationId = stationId
        self.systemId = systemId
        self.typeId = typeId
    }

    public enum CodingKeys: String, CodingKey {
        case maxDockableShipVolume = "max_dockable_ship_volume"
        case name
        case officeRentalCost = "office_rental_cost"
        case owner
        case position
        case raceId = "race_id"
        case reprocessingEfficiency = "reprocessing_efficiency"
        case reprocessingStationsTake = "reprocessing_stations_take"
        case services
        case stationId = "station_id"
        case systemId = "system_id"
        case typeId = "type_id"
    }

}
