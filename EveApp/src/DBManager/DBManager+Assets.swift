//
//  DBManager+assets.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/14/25.
//

import Foundation
import Fluent
import FluentSQL
import FluentPostgresDriver
import ModelLibrary


// MARK: - Assets

extension DBManager {
    
    /// Retrieves assets for a specific character, filtered by location type 'station' and joined with type information.
    /// - Parameters:
    ///   - characterId: The unique identifier of the character whose assets are to be retrieved.
    /// - Returns: An optional array of `CharacterAssetsDataModel` instances if successful, `nil` if the character is not found or an error occurs.
    /// - Note: Errors are logged to the console but not thrown. The results are sorted by `locationFlag`.
    func getAssetsForCharacter(characterId: String) async -> [CharacterAssetsDataModel]? {
        print("getAssetsForCharacter \(characterId)")
        guard let character = await getCharacterWithInfo(characterId: characterId) else {
            return nil
        }
        
        do {
            let locationFlags: [String] = [
                GetCharactersCharacterIdAssets200Ok.LocationFlag.hangar.rawValue
            ]
            // CharacterAssetDataModels that are in a station with related TypeModel loaded
            let characterAssets = try await character.$assetsData.query(on: self.database)
                .filter(\.$locationFlag ~~ locationFlags)
                .join(TypeModel.self, on: \CharacterAssetsDataModel.$typeId == \TypeModel.$typeId) //.join(StationInfoModel.self, on: \CharacterAssetsDataModel.$locationId == \StationInfoModel.$stationId)
                .all()
                .get()
                .sorted(by: {$0.locationFlag < $1.locationFlag})
            return characterAssets
        } catch let error {
            print("++ Loading assets for character error: \(String(reflecting: error))")
            return nil
        }
    }
    
    func getAllAssetsForCharacter(characterId: String) async -> [CharacterAssetsDataModel]? {
        print("getAssetsForCharacter \(characterId)")
        guard let character = await getCharacterWithInfo(characterId: characterId) else {
            return nil
        }
        
        do {
            // CharacterAssetDataModels that are in a station with related TypeModel loaded
            let characterAssets = try await character.$assetsData.query(on: self.database)
                .join(TypeModel.self, on: \CharacterAssetsDataModel.$typeId == \TypeModel.$typeId)
                .all()
                .get()
                .sorted(by: {$0.locationFlag < $1.locationFlag})
            return characterAssets
        } catch let error {
            print("++ Loading assets for character error: \(String(reflecting: error))")
            return nil
        }
    }
    
    func getAssetsInAnyStructure(characterId: String) async -> [CharacterAssetsDataModel]? {
        guard let character = await getCharacterWithInfo(characterId: characterId) else {
            return []
        }
        let locationType: GetCharactersCharacterIdAssets200Ok.LocationType = .item
        let locationFlag: GetCharactersCharacterIdAssets200Ok.LocationFlag = .hangar
        
        let locationTypes: [GetCharactersCharacterIdAssets200Ok.LocationType] = [.station, .item]
        let locationFlags: [GetCharactersCharacterIdAssets200Ok.LocationFlag] = [.hangar, .autoFit]
        let characterAssets = try? await character.$assetsData.query(on: self.database)
            .filter(\.$locationType == locationType.rawValue)
            .filter(\.$locationFlag ~~ locationFlags.map { $0.rawValue })
            .join(
                TypeModel.self,
                on: \CharacterAssetsDataModel.$typeId == \TypeModel.$typeId
            )
            .all()
            .get()
            .sorted(by: {$0.locationId < $1.locationId})
        return characterAssets
    }
    
    func getAsset(with itemId: Int64) async -> CharacterAssetsDataModel? {
        return try? await CharacterAssetsDataModel.query(on: self.database)
            .filter(\.$itemId == itemId)
            .first()
    }
    
    // Currently this gets all assets inside a player owned station that has a related StationInfoModel.
    // Then sorts the assets by location_id and groups related assets inside other assets to display
    func getAssetsTest(characterId: String) async -> [IdentifiedStringQuantity] {
        guard let character = await getCharacterWithInfo(characterId: characterId) else {
            return []
        }
        
        guard let characterAssets = await getAssetsInAnyStructure(characterId: characterId) else {
            print("No assets in known structure for \(characterId)")
            return []
        }
        
        var assetIds: Set<Int64> = []
        var groupedAssets: [Int64: [CharacterAssetsDataModel]] = [:]
        
        // Group assets
        for asset in characterAssets {
            let existing = groupedAssets[asset.locationId, default: []]
            groupedAssets[asset.locationId] = existing + [asset]
            assetIds.insert(asset.itemId)
        }
        
        let identifiedStrings = await makeDisplayObjects(for: groupedAssets, assetIds: assetIds)
        return identifiedStrings
    }
    
    // Creates `IdentifiedStringQuantity`
    func makeDisplayObjects(
        for groupedAssets: [Int64: [CharacterAssetsDataModel]],
        assetIds: Set<Int64>
    ) async -> [IdentifiedStringQuantity] {
        var identifiedStrings: [IdentifiedStringQuantity] = []
        print("++ makeDisplayObjects for \(groupedAssets.count) groups")
        for (locationId, assetGroup) in groupedAssets {
            print("++ group for \(locationId)")
            // Make sure the key, location_id, is not another asset
            guard !assetIds.contains(locationId) else {
                continue
            }
            
            //if let related = groupedAssets[]
            let identifiedStringQuantityValues = assetGroup.compactMap { value -> IdentifiedStringQuantity? in
                var childAssetsIdentifiable: [IdentifiedStringQuantity]? = nil
                
                if let childAssets = groupedAssets[value.itemId] {
                    print("++ has child assets")
                    let groupedChildAssets = groupAssets(data: childAssets)
                    let processedObjects = makeObjects(groupedAssets: groupedChildAssets)
                    childAssetsIdentifiable = processedObjects
                }
                
                guard let typeModel = try? value.joined(TypeModel.self) else { return nil }
                
                return IdentifiedStringQuantity(
                    id: value.itemId,
                    value: typeModel.name,
                    quantity: Int64(childAssetsIdentifiable?.count ?? Int(value.quantity)),
                    content: childAssetsIdentifiable
                )
            }
            let stationInfoModel = await self.getStationInfoModel(stationId: locationId)
            let thisOne = IdentifiedStringQuantity(
                id: locationId,
                value: stationInfoModel?.name ?? String(locationId),
                quantity: Int64(assetGroup.count),
                content: identifiedStringQuantityValues
            )
            identifiedStrings.append(thisOne)
        }

        return identifiedStrings
    }
    
    func groupAssets(data: [CharacterAssetsDataModel]) -> [Int64: [CharacterAssetsDataModel]] {
        print("++ groupAssets")
        var groupedAssets: [Int64: [CharacterAssetsDataModel]] = [:]
        for asset in data {
            guard let typeModel = try? asset.joined(TypeModel.self) else {
                continue
            }
            let existingAssets = groupedAssets[typeModel.groupID, default: []]
            groupedAssets[typeModel.groupID] = existingAssets + [asset]
        }
        
        return groupedAssets
    }
    
    func makeObjects2(assets: [CharacterAssetsDataModel]) -> [IdentifiedStringQuantity] {
        let assetThing = assets.compactMap { asset -> IdentifiedStringQuantity? in
            guard let typeModel = try? asset.joined(TypeModel.self) else {
                return nil
            }
            
            return IdentifiedStringQuantity(
                id: asset.itemId,
                value: typeModel.name,
                quantity: asset.quantity
            )
        }
        return assetThing
    }
    
    func makeObjects(groupedAssets: [Int64: [CharacterAssetsDataModel]]) -> [IdentifiedStringQuantity] {
        var returnValues: [IdentifiedStringQuantity] = []
        var groupNames: [Int64: String] = [:]
        print("++ makeObjects")
        for assetGroup in groupedAssets {
            let groupId = assetGroup.key
            let assetsInGroup = assetGroup.value
            
            // the IdentifiedStringQuantities for the asset group
            let assetThing = makeObjects2(assets: assetsInGroup)
//            returnValues.append(contentsOf: assetThing)
            if let existingGroupName = groupNames[groupId] {
                print("++ existing group name \(existingGroupName)")
                let someValue = IdentifiedStringQuantity(
                    id: groupId,
                    value: existingGroupName,
                    quantity: Int64(assetsInGroup.count),
                    content: assetThing
                )
                returnValues.append(someValue)
            } else {
                guard let groupModel = self.getGroup(for: groupId) else {
                    continue
                }
                print("++ new groupModel \(groupModel.name)")
                groupNames[groupId] = groupModel.name

                let someValue = IdentifiedStringQuantity(
                    id: groupId,
                    value: groupModel.name,
                    quantity: Int64(assetsInGroup.count),
                    content: assetThing
                )
                returnValues.append(someValue)
            }
        }
        return returnValues
    }
}

// MARK: - StationInfoModel

extension DBManager {

    func getStationInfoModel(stationId: Int64) async -> StationInfoModel? {
        return try? await StationInfoModel.query(on: self.database)
            .filter(\.$stationId == stationId)
            .first()
    }

}
