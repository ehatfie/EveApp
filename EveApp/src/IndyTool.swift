//
//  IndyTool.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/24/24.
//
import Foundation
import ModelLibrary

struct IndyJob {
    
}

class IndyTool {
    let dbManager: DBManager
    var characterID: String? = nil
    var relatedAssets: [Int64: Int64] = [:]
    
    init(dbManager: DBManager) {
        self.dbManager = dbManager
        characterID = dbManager.getCharacters().first?.characterId
    }
    
    func getMissingInputs(blueprintID: Int64, quantity: Int64) async -> [Int64: Int64] {
        guard let bpInfo = await makeBPInfo(for: blueprintID) else {
            return [:] //[blueprintID: quantity]
        }
        let missingInputs = await findMissingInputs(
            bpInfos: [bpInfo],
            values: [bpInfo.productId: quantity],
            depth: 0
        )
        return missingInputs
        print("got missing inputs \(missingInputs)")
    }
    
    func findMissingInputs(
        bpInfos: [BPInfo],
        values: [Int64: Int64],
        depth: Int
    ) async -> [Int64: Int64] {
        var returnValues: [Int64: Int64] = [:]
        let inputProducts = bpInfos.flatMap { $0.inputMaterials.map { $0.id }}
        await loadCharacterAssets(for: inputProducts)
        //let assets = dbManager.getCharacterAssetsForValues(characterID: 0, typeIds: inputProducts)
        for bpInfo in bpInfos {
            let parentAmountNeeded = values[bpInfo.productId, default: 0]
            let productsPerRun = bpInfo.productCount
            let runsNeeded = Int64(ceil(Double(parentAmountNeeded) / Double(productsPerRun)))
            for input in bpInfo.inputMaterials {
                let amountNeeded = input.quantity * runsNeeded
                
                guard amountNeeded > 0 else {
                    print("no runs for \(bpInfo.blueprintId)")
                    continue
                }
                if input.id == 16672 {
                    print("\(bpInfo.productId) input count \(input.quantity)")
                }
                //returnValues[input.id, default: 0] += runsNeeded * input.quantity
                guard BlueprintIds.FuelBlocks(rawValue: input.id) == nil else {
                    continue
                }
                let matchingAssetQuantity = relatedAssets[input.id, default: 0]
                let amountMissing = max(0, amountNeeded - matchingAssetQuantity)
 
                guard amountMissing > 0 else { continue }
                print("Adding missing input \(input.id) matching \(matchingAssetQuantity) needed \(amountNeeded) missing \(amountMissing)")
                returnValues[input.id] = amountMissing
            }
        }
        
        return returnValues
    }
    
    func makeJobs(for values: [Int64: Int64]) -> [IndyJob] {
        return []
    }
    
    func loadCharacterAssets(for typeIds: [Int64]) async {
        guard let characterID else {
            print("no character ID")
            return
        }
        let fetchedIds: Set<Int64> = Set(relatedAssets.map { $0.key})
        let missingIds: Set<Int64> = Set(typeIds).subtracting(fetchedIds)
        print("provided \(typeIds.count) fetching \(missingIds.count)")
        let assets = await dbManager.getCharacterAssetsForValues(
            characterID: characterID,
            typeIds: Array(missingIds)
        )
        for asset in assets {
            relatedAssets[asset.typeId] = asset.quantity
        }
    }
    
    func makeBPInfo(for blueprintId: Int64) async -> BPInfo? {
        let blueprintModel: BlueprintModel?
        
        if let bp = await dbManager.getBlueprintModel(for: blueprintId) {
            blueprintModel = bp
        } else if let bp = await dbManager.getManufacturingBlueprintAsync(making: blueprintId) {
            blueprintModel = bp
        } else if let bp = await dbManager.getReactionBlueprintAsync(for: blueprintId) {
            blueprintModel = bp
        } else {
            blueprintModel = nil
        }
        
        guard let bpModel = blueprintModel else {
            return nil
        }
        
        return makeBPInfo(for: bpModel)
    }
    
    func makeBPInfo(for bpModel: BlueprintModel) -> BPInfo? {
        let product: QuantityTypeModel?
        
        if let prod = bpModel.activities.manufacturing.products.first {
            product = prod
        } else if let prod = bpModel.activities.reaction.products.first {
            product = prod
        } else {
            product = nil
        }
        
        guard let product = product else {
            return nil
        }
        
        let activities = bpModel.activities
        
        let inputMaterials = (activities.manufacturing.materials + activities.reaction.materials)
            .map { IdentifiedQuantity(id: $0.typeId, quantity: $0.quantity) }
        
        //let foo = dbManager.getGroup
        
        return BPInfo(
            productId: product.typeId,
            productCount: product.quantity,
            blueprintId: bpModel.blueprintTypeID,
            inputMaterials: inputMaterials
        )
    }
}
