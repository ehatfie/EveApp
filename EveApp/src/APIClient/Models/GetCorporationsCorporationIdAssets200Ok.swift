//
// GetCorporationsCorporationIdAssets200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCorporationsCorporationIdAssets200Ok: Codable {

    public enum LocationFlag: String, Codable { 
        case assetSafety = "AssetSafety"
        case autoFit = "AutoFit"
        case bonus = "Bonus"
        case booster = "Booster"
        case boosterBay = "BoosterBay"
        case capsule = "Capsule"
        case cargo = "Cargo"
        case corpDeliveries = "CorpDeliveries"
        case corpSAG1 = "CorpSAG1"
        case corpSAG2 = "CorpSAG2"
        case corpSAG3 = "CorpSAG3"
        case corpSAG4 = "CorpSAG4"
        case corpSAG5 = "CorpSAG5"
        case corpSAG6 = "CorpSAG6"
        case corpSAG7 = "CorpSAG7"
        case corporationGoalDeliveries = "CorporationGoalDeliveries"
        case crateLoot = "CrateLoot"
        case deliveries = "Deliveries"
        case droneBay = "DroneBay"
        case dustBattle = "DustBattle"
        case dustDatabank = "DustDatabank"
        case fighterBay = "FighterBay"
        case fighterTube0 = "FighterTube0"
        case fighterTube1 = "FighterTube1"
        case fighterTube2 = "FighterTube2"
        case fighterTube3 = "FighterTube3"
        case fighterTube4 = "FighterTube4"
        case fleetHangar = "FleetHangar"
        case frigateEscapeBay = "FrigateEscapeBay"
        case hangar = "Hangar"
        case hangarAll = "HangarAll"
        case hiSlot0 = "HiSlot0"
        case hiSlot1 = "HiSlot1"
        case hiSlot2 = "HiSlot2"
        case hiSlot3 = "HiSlot3"
        case hiSlot4 = "HiSlot4"
        case hiSlot5 = "HiSlot5"
        case hiSlot6 = "HiSlot6"
        case hiSlot7 = "HiSlot7"
        case hiddenModifiers = "HiddenModifiers"
        case implant = "Implant"
        case impounded = "Impounded"
        case junkyardReprocessed = "JunkyardReprocessed"
        case junkyardTrashed = "JunkyardTrashed"
        case loSlot0 = "LoSlot0"
        case loSlot1 = "LoSlot1"
        case loSlot2 = "LoSlot2"
        case loSlot3 = "LoSlot3"
        case loSlot4 = "LoSlot4"
        case loSlot5 = "LoSlot5"
        case loSlot6 = "LoSlot6"
        case loSlot7 = "LoSlot7"
        case locked = "Locked"
        case medSlot0 = "MedSlot0"
        case medSlot1 = "MedSlot1"
        case medSlot2 = "MedSlot2"
        case medSlot3 = "MedSlot3"
        case medSlot4 = "MedSlot4"
        case medSlot5 = "MedSlot5"
        case medSlot6 = "MedSlot6"
        case medSlot7 = "MedSlot7"
        case mobileDepotHold = "MobileDepotHold"
        case officeFolder = "OfficeFolder"
        case pilot = "Pilot"
        case planetSurface = "PlanetSurface"
        case quafeBay = "QuafeBay"
        case quantumCoreRoom = "QuantumCoreRoom"
        case reward = "Reward"
        case rigSlot0 = "RigSlot0"
        case rigSlot1 = "RigSlot1"
        case rigSlot2 = "RigSlot2"
        case rigSlot3 = "RigSlot3"
        case rigSlot4 = "RigSlot4"
        case rigSlot5 = "RigSlot5"
        case rigSlot6 = "RigSlot6"
        case rigSlot7 = "RigSlot7"
        case secondaryStorage = "SecondaryStorage"
        case serviceSlot0 = "ServiceSlot0"
        case serviceSlot1 = "ServiceSlot1"
        case serviceSlot2 = "ServiceSlot2"
        case serviceSlot3 = "ServiceSlot3"
        case serviceSlot4 = "ServiceSlot4"
        case serviceSlot5 = "ServiceSlot5"
        case serviceSlot6 = "ServiceSlot6"
        case serviceSlot7 = "ServiceSlot7"
        case shipHangar = "ShipHangar"
        case shipOffline = "ShipOffline"
        case skill = "Skill"
        case skillInTraining = "SkillInTraining"
        case specializedAmmoHold = "SpecializedAmmoHold"
        case specializedAsteroidHold = "SpecializedAsteroidHold"
        case specializedCommandCenterHold = "SpecializedCommandCenterHold"
        case specializedFuelBay = "SpecializedFuelBay"
        case specializedGasHold = "SpecializedGasHold"
        case specializedIceHold = "SpecializedIceHold"
        case specializedIndustrialShipHold = "SpecializedIndustrialShipHold"
        case specializedLargeShipHold = "SpecializedLargeShipHold"
        case specializedMaterialBay = "SpecializedMaterialBay"
        case specializedMediumShipHold = "SpecializedMediumShipHold"
        case specializedMineralHold = "SpecializedMineralHold"
        case specializedOreHold = "SpecializedOreHold"
        case specializedPlanetaryCommoditiesHold = "SpecializedPlanetaryCommoditiesHold"
        case specializedSalvageHold = "SpecializedSalvageHold"
        case specializedShipHold = "SpecializedShipHold"
        case specializedSmallShipHold = "SpecializedSmallShipHold"
        case structureActive = "StructureActive"
        case structureFuel = "StructureFuel"
        case structureInactive = "StructureInactive"
        case structureOffline = "StructureOffline"
        case subSystemBay = "SubSystemBay"
        case subSystemSlot0 = "SubSystemSlot0"
        case subSystemSlot1 = "SubSystemSlot1"
        case subSystemSlot2 = "SubSystemSlot2"
        case subSystemSlot3 = "SubSystemSlot3"
        case subSystemSlot4 = "SubSystemSlot4"
        case subSystemSlot5 = "SubSystemSlot5"
        case subSystemSlot6 = "SubSystemSlot6"
        case subSystemSlot7 = "SubSystemSlot7"
        case unlocked = "Unlocked"
        case wallet = "Wallet"
        case wardrobe = "Wardrobe"
    }
    public enum LocationType: String, Codable { 
        case station = "station"
        case solarSystem = "solar_system"
        case item = "item"
        case other = "other"
    }
    /** is_blueprint_copy boolean */
    public var isBlueprintCopy: Bool?
    /** is_singleton boolean */
    public var isSingleton: Bool
    /** item_id integer */
    public var itemId: Int64
    /** location_flag string */
    public var locationFlag: LocationFlag
    /** location_id integer */
    public var locationId: Int64
    /** location_type string */
    public var locationType: LocationType
    /** quantity integer */
    public var quantity: Int
    /** type_id integer */
    public var typeId: Int

    public init(isBlueprintCopy: Bool? = nil, isSingleton: Bool, itemId: Int64, locationFlag: LocationFlag, locationId: Int64, locationType: LocationType, quantity: Int, typeId: Int) {
        self.isBlueprintCopy = isBlueprintCopy
        self.isSingleton = isSingleton
        self.itemId = itemId
        self.locationFlag = locationFlag
        self.locationId = locationId
        self.locationType = locationType
        self.quantity = quantity
        self.typeId = typeId
    }

    public enum CodingKeys: String, CodingKey { 
        case isBlueprintCopy = "is_blueprint_copy"
        case isSingleton = "is_singleton"
        case itemId = "item_id"
        case locationFlag = "location_flag"
        case locationId = "location_id"
        case locationType = "location_type"
        case quantity
        case typeId = "type_id"
    }

}
