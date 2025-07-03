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
                if quantity == 0 {
                    print("++ testGetMissingInputs quantity \(quantity)")
                }
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

// MARK: - Jobs stuff

extension IndyTool {
    
    func testMakeJobsForMissingInputs(missingInputs: [Int64: Int64]) async -> [TestJob] {
        let start = Date()
        
        let missingInputIds = missingInputs.keys.map { $0 }
        
        let missingInputBlueprints = await makeBPInfos(for: missingInputIds)
        
        var uniqueBPs: [Int64: BPInfo] = [:]
        
        missingInputBlueprints.forEach { value in
          guard BlueprintIds.FuelBlocks(rawValue: value.productId) == nil else {
            return
          }
          uniqueBPs[value.productId] = value
        }
        
        let jobs: [TestJob] = missingInputIds.compactMap { key -> TestJob? in
          guard let value = missingInputs[key] else {
            return nil
          }
          guard let blueprintInfo = uniqueBPs[key] else {
            return nil
          }
          let inputQuantity = value
          let productsPerRun = blueprintInfo.productCount
          let requiredRuns = Int(ceil(Double(inputQuantity) / Double(productsPerRun)))
            if requiredRuns == 0 {
                let one = Double(inputQuantity) / Double(productsPerRun)
                let ceil = ceil(one)
                print("++ inputQuantity \(inputQuantity) productsPerRun \(productsPerRun) one \(one), ceil \(ceil)")
            }
          return TestJob(
            quantity: Int64(value),
            productId: blueprintInfo.productId,
            inputs: blueprintInfo.inputMaterials,
            blueprintId: blueprintInfo.blueprintId,
            productsPerRun: Int(blueprintInfo.productCount),
            requiredRuns: requiredRuns
          )
        }
        
        print("++ testMakeJobsForMissingInputs took \(abs(start.timeIntervalSinceNow))")
        return jobs
    }
    
    func makeJobsForJobs(_ jobs: [TestJob]) async -> [TestJob] {
        var requiredInputs: [Int64: Int64] = [:]
        
        for job in jobs {
            
            // sum the inputs
            // this could be the async for each technically
            for input in job.inputs {
                if input.quantity == 0 || job.requiredRuns == 0 {
                    print("jobForJob quantity \(input.quantity) requiredRuns \(job.requiredRuns)")
                }
                requiredInputs[input.id, default: 0] += input.quantity * Int64(job.requiredRuns)
            }
        }
        
        let missingInputs = await testFindMissingInputs(values: requiredInputs)
        
        guard !missingInputs.isEmpty else {
            return jobs
        }
        
        let jobsForInputs = await testMakeJobsForMissingInputs(
            missingInputs: missingInputs
        )
        
        return jobs + jobsForInputs
    }
    
    func makeJobsForInputs(_ inputs: [Int64: Int64]) async -> [TestJob] {
        
        return []
    }
    
    
}
