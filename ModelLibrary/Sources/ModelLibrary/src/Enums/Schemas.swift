//
//  Schemas.swift
//  
//
//  Created by Erik Hatfield on 8/20/24.
//
import Foundation

public enum Schemas: String {
    case categories = "categories"
    case groups = "groups"
    case dogmaEffect = "dogmaEffect"
    case dogmaAttribute = "dogmaAttribute"
    case typeDogma = "typeDogma"
    case typeDogmaInfo = "typeDogmaInfo"
    case typeDogmaAttributeInfo = "typeDogmaAttributeInfo"
    case typeDogmaEffectInfo = "typeDogmaEffectInfo"
    case materialDataModel = "materialDataModel"
    case typeMaterialsModel = "typeMaterialsModel"
    case blueprintModel = "blueprintModel"
    case raceModel = "raceModel"
    case locationModel = "locationModel"
    case stationOperation = "stationOperation"
    
    case characterDataModel = "characterDataModel"
    case characterPublicDataModel = "characterPublicDataModel"
    case characterAssetsDataModel = "characterAssetsDataModel"
    case characterSkillsDataModel = "characterSkillsDataModel"
    case characterSkillModel = "characterSkillModel"
    case characterIndustryDataModel = "characterIndustryDataModel"
    case characterIndustryJobModel = "characterIndustryJobModel"
    
    case characterWalletModel = "characterWalletModel"
    case characterWalletJournalEntryModel = "characterWalletJournalEntryModel"
    case characterWalletTransactionModel = "characterWalletTransactionModel"
    
    case characterIdentifiersModel = "characterIdentifiersModel"

    case corporationInfoModel = "corporationInfoModel"
    
    case characterCorporationModel = "characterCorporationModel"
    
    case auth = "authModel"
    
    public enum Killmail: String {
        case zkill = "zkill"
        case esi = "esi"
    }
    
    public enum Universe: String {
        case solarSystems = "solarSystems"
    }
}
