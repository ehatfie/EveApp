//
// GetCharactersCharacterIdBlueprints200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCharactersCharacterIdBlueprints200Ok: Codable {

    public enum LocationFlag: String, Codable { 
        case autoFit = "AutoFit"
        case cargo = "Cargo"
        case corpseBay = "CorpseBay"
        case droneBay = "DroneBay"
        case fleetHangar = "FleetHangar"
        case deliveries = "Deliveries"
        case hiddenModifiers = "HiddenModifiers"
        case hangar = "Hangar"
        case hangarAll = "HangarAll"
        case loSlot0 = "LoSlot0"
        case loSlot1 = "LoSlot1"
        case loSlot2 = "LoSlot2"
        case loSlot3 = "LoSlot3"
        case loSlot4 = "LoSlot4"
        case loSlot5 = "LoSlot5"
        case loSlot6 = "LoSlot6"
        case loSlot7 = "LoSlot7"
        case medSlot0 = "MedSlot0"
        case medSlot1 = "MedSlot1"
        case medSlot2 = "MedSlot2"
        case medSlot3 = "MedSlot3"
        case medSlot4 = "MedSlot4"
        case medSlot5 = "MedSlot5"
        case medSlot6 = "MedSlot6"
        case medSlot7 = "MedSlot7"
        case hiSlot0 = "HiSlot0"
        case hiSlot1 = "HiSlot1"
        case hiSlot2 = "HiSlot2"
        case hiSlot3 = "HiSlot3"
        case hiSlot4 = "HiSlot4"
        case hiSlot5 = "HiSlot5"
        case hiSlot6 = "HiSlot6"
        case hiSlot7 = "HiSlot7"
        case assetSafety = "AssetSafety"
        case locked = "Locked"
        case unlocked = "Unlocked"
        case implant = "Implant"
        case quafeBay = "QuafeBay"
        case rigSlot0 = "RigSlot0"
        case rigSlot1 = "RigSlot1"
        case rigSlot2 = "RigSlot2"
        case rigSlot3 = "RigSlot3"
        case rigSlot4 = "RigSlot4"
        case rigSlot5 = "RigSlot5"
        case rigSlot6 = "RigSlot6"
        case rigSlot7 = "RigSlot7"
        case shipHangar = "ShipHangar"
        case specializedFuelBay = "SpecializedFuelBay"
        case specializedOreHold = "SpecializedOreHold"
        case specializedGasHold = "SpecializedGasHold"
        case specializedMineralHold = "SpecializedMineralHold"
        case specializedSalvageHold = "SpecializedSalvageHold"
        case specializedShipHold = "SpecializedShipHold"
        case specializedSmallShipHold = "SpecializedSmallShipHold"
        case specializedMediumShipHold = "SpecializedMediumShipHold"
        case specializedLargeShipHold = "SpecializedLargeShipHold"
        case specializedIndustrialShipHold = "SpecializedIndustrialShipHold"
        case specializedAmmoHold = "SpecializedAmmoHold"
        case specializedCommandCenterHold = "SpecializedCommandCenterHold"
        case specializedPlanetaryCommoditiesHold = "SpecializedPlanetaryCommoditiesHold"
        case specializedMaterialBay = "SpecializedMaterialBay"
        case subSystemSlot0 = "SubSystemSlot0"
        case subSystemSlot1 = "SubSystemSlot1"
        case subSystemSlot2 = "SubSystemSlot2"
        case subSystemSlot3 = "SubSystemSlot3"
        case subSystemSlot4 = "SubSystemSlot4"
        case subSystemSlot5 = "SubSystemSlot5"
        case subSystemSlot6 = "SubSystemSlot6"
        case subSystemSlot7 = "SubSystemSlot7"
        case fighterBay = "FighterBay"
        case fighterTube0 = "FighterTube0"
        case fighterTube1 = "FighterTube1"
        case fighterTube2 = "FighterTube2"
        case fighterTube3 = "FighterTube3"
        case fighterTube4 = "FighterTube4"
        case module = "Module"
    }
    /** Unique ID for this item. */
    public var itemId: Int64
    /** Type of the location_id */
    public var locationFlag: LocationFlag
    /** References a station, a ship or an item_id if this blueprint is located within a container. If the return value is an item_id, then the Character AssetList API must be queried to find the container using the given item_id to determine the correct location of the Blueprint. */
    public var locationId: Int64
    /** Material Efficiency Level of the blueprint. */
    public var materialEfficiency: Int
    /** A range of numbers with a minimum of -2 and no maximum value where -1 is an original and -2 is a copy. It can be a positive integer if it is a stack of blueprint originals fresh from the market (e.g. no activities performed on them yet). */
    public var quantity: Int
    /** Number of runs remaining if the blueprint is a copy, -1 if it is an original. */
    public var runs: Int
    /** Time Efficiency Level of the blueprint. */
    public var timeEfficiency: Int
    /** type_id integer */
    public var typeId: Int

    public init(itemId: Int64, locationFlag: LocationFlag, locationId: Int64, materialEfficiency: Int, quantity: Int, runs: Int, timeEfficiency: Int, typeId: Int) {
        self.itemId = itemId
        self.locationFlag = locationFlag
        self.locationId = locationId
        self.materialEfficiency = materialEfficiency
        self.quantity = quantity
        self.runs = runs
        self.timeEfficiency = timeEfficiency
        self.typeId = typeId
    }

    public enum CodingKeys: String, CodingKey { 
        case itemId = "item_id"
        case locationFlag = "location_flag"
        case locationId = "location_id"
        case materialEfficiency = "material_efficiency"
        case quantity
        case runs
        case timeEfficiency = "time_efficiency"
        case typeId = "type_id"
    }

}
