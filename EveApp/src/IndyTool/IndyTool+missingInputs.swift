//
//  IndyTool+missingInputs.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/25/25.
//

import Foundation
import ModelLibrary

extension IndyTool {
    
    func testFindMissingInputs(
        values: [Int64: Int64],
        depth: Int = 0
    ) async -> [Int64: Int64] {
        guard !values.isEmpty else {
          return [:]
        }
        let start = Date()
        
        let bpInfos = await makeBPInfos(for: Array(values.keys))
        //let results = bpInfos.map { ($0.blueprintId, $0.productId) }
        let missingInputs = await testGetMissingInputs(
            bpInfos: bpInfos,
            values: values,
            depth: depth
        )
        print("++ testFindMissingInputs took \(Date().timeIntervalSince(start))")
        return missingInputs
    }
    
    // this doesnt currently check if we have the original thing only the inputs
    func testGetMissingInputs(
        bpInfos: [BPInfo],
        values: [Int64: Int64],
        depth: Int
    ) async -> [Int64: Int64] {
        
        let inputSums = await sumInputs1(on: bpInfos, values: values)
        
        if let characterID {
            let inputIds = Array(inputSums.keys)
            
            await loadAssets(characterId: characterID, typeIds: inputIds)
        }
        var missingInputs: [Int64: Int64] = [:]
        
        for (inputId, quantity) in inputSums {
            //let relatedAssetQuantity = relatedAssets[inputId, default: 0]
            // if there is a matching character asset use the existing quantity
            if let matchingAssetQuantity = relatedAssets[inputId] {
              // Diff is negative if we dont have enough
              let diff = min(matchingAssetQuantity - quantity, 0)
              // ignore any amount that isnt negative
              guard diff < 0 else { continue }
              // insert a non-negative number
              missingInputs[inputId] = abs(diff)
            } else {
              missingInputs[inputId] = quantity
            }
        }
        
        let missingBPInfos = await makeBPInfos(for: Array(missingInputs.keys))
        guard !missingBPInfos.isEmpty else { return missingInputs }
        
        let nextMissingInputs = await testGetMissingInputs(
            bpInfos: missingBPInfos,
            values: missingInputs,
            depth: depth + 1
        )
        return missingInputs.merging(
            nextMissingInputs,
            uniquingKeysWith: +
        )
    }
    
    func loadAssets(characterId: String, typeIds: [Int64]) async {
        // we only want assets we dont already have
        let unfetchedTypeIds = typeIds.compactMap { value -> Int64? in
         guard relatedAssets[value] == nil else { return nil }
            return value
        }
        
        guard !unfetchedTypeIds.isEmpty else { return }
        
        let fetchedCharacterAssets = await dbManager.getCharacterAssetsForValues(
            characterID: characterId,
            typeIds: unfetchedTypeIds
        )
        print("++ got relatedCharacterAsset \(fetchedCharacterAssets.count)")
        
        for asset in fetchedCharacterAssets {
            relatedAssets[asset.typeId] = asset.quantity
        }
    }
    
    
    
}
