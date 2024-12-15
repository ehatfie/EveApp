//
//  IPM+processing.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/31/24.
//

import Foundation
import ModelLibrary

extension IndustryPlannerManager {
    func itemInputBreakdown() {
        
    }
    
    func breakdownInputs(for typeID: Int64, quantity: Int64, depth: Int = 0) async -> [Int64: Int64]? {
        guard BlueprintIds.FuelBlocks(rawValue: typeID) == nil else {
            return [typeID: quantity]
        }
        
        guard let bpInfo = await makeBPInfo(for: typeID) else {
            return [typeID: quantity]
        }
        
        return await breakdownModelInputs(for: bpInfo, quantity: quantity, depth: depth)
    }
    
    func printNames(
        root: TypeNamesResult? = nil,
        _ names: [TypeNamesResult],
        values: [Int64: Int64] = [:],
        depth: Int
    ) {
        //print()
        //print("printNames values \(values)")
        if let root {
            //print("\(root.name) \(root.typeId) depth: \(depth)")
        }
        for name in names {
            let count = values[name.typeId, default: 0]
            //print("\(String(repeating: "\t", count: depth)) (\(name.typeId)) \(name.name) \(count)")
        }
    }
    
    func breakdownModelInputs(for bpInfo: BPInfo, quantity: Int64, depth: Int) async -> [Int64: Int64]? {
        var inputsDict: [Int64: Int64] = [:]
        let inputs = bpInfo.inputMaterials
        //print("depth \(depth)")
        let runsNeeded = ceil(Double(quantity) / Double(bpInfo.productCount))
        
        for input in inputs {
            inputsDict[input.id] = input.quantity * Int64(runsNeeded)
        }
        //let startName = await dbManager.getType(for: [])
        let bpNames = await dbManager.getTypeNames(for: [bpInfo.productId])
        
        // this means we are at a bottom level item/input
        guard !inputsDict.isEmpty else {
            print("empty inputs dict")
            return nil
        }
        
        let inputIds = inputs.map { $0.id }
        let uniqueInputs = Set(inputIds)
        
        let bpInfos: [BPInfo] = await makeBPInfo(for: uniqueInputs)
        
        let inputBpNames = await dbManager.getTypeNames(for: bpInfos.map { $0.blueprintId})
        printNames(root: bpNames.first!, inputBpNames, depth: depth)
        
        guard !bpInfos.isEmpty else {
            print("empty bpInfos \(inputsDict)")
            return inputsDict
        }
        
        // we want the inputs for this array next
        var summs: [Int64: Int64] = await sumAdjustedInputs(
            bpInfos: bpInfos,
            values: inputsDict,
            depth: depth
        )
        
        let summedInputs: [Int64: Int64] = await withTaskGroup(
            of: [Int64: Int64]?.self,
            returning: [Int64: Int64].self
        ) { taskGroup in
            for (key, value) in inputsDict {
                taskGroup.addTask {
                    return await self.breakdownInputs(for: key, quantity: value, depth: depth + 1)
                }
            }
            
            var returnValues: [Int64: Int64] = [:]
            
            for await result in taskGroup {
                guard let result = result else { continue }
                returnValues.merge(
                    result,
                    uniquingKeysWith: { return $0 + $1 }
                )
            }
            
            return returnValues
        }
        //print("summs \(summs.count) summedInputs \(summedInputs.count)")
        //summedInputs.merge(inputsDict, uniquingKeysWith: { $0 + $1})
        summs.merge(summedInputs, uniquingKeysWith: { $0 + $1 })
        summs.merge(inputsDict, uniquingKeysWith: { $0 + $1})
        return summs
    }
    
    func sumInputs(on bpInfos: [BPInfo], values: [Int64: Int64]) async -> [Int64: Int64] {
        var inputsDict: [Int64: Int64] = [:]
        
        for bpInfo in bpInfos {
            let bpInputs = await sumAdjustedInputs(bpInfo: bpInfo, values: values)
            
            inputsDict.merge(bpInputs, uniquingKeysWith: +)
        }
        
        return inputsDict
    }
    
    func sumAdjustedInputs2(
        blueprintModel: BPInfo,
        quantity: Int64
    ) async -> [Int64: Int64] {
        //let runsToMake = quantity / blueprintModel.activities.manufacturing.products
        return [:]
    }
    
    func makeBPInfo(for blueprintIds: Set<Int64>) async -> [BPInfo] {
        let manufacturingValues = await dbManager.getManufacturingBlueprintsAsync(making: Array(blueprintIds))
        let reactionValues = await dbManager.getReactionBlueprintsAsync(making: Array(blueprintIds))
        
        return await makeBPInfo(for: manufacturingValues + reactionValues)
    }
    
    func makeBPInfo(for blueprintModels: [BlueprintModel]) async -> [BPInfo] {
        return blueprintModels.compactMap { makeBPInfo(for: $0) }
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
    
    func sumAdjustedInputs(bpInfo: BPInfo, values: [Int64: Int64]) async -> [Int64: Int64] {
        let typeID = bpInfo.productId
        // Dont want to make fuel blocks
        guard BlueprintIds.FuelBlocks(rawValue: typeID) == nil else {
            return [bpInfo.productId: values[bpInfo.productId, default: 0]]
        }
        guard let numToMake = values[bpInfo.productId],
                numToMake > 0
        else {
            print("no count for \(bpInfo.productId)")
            return [:]
        }
        if bpInfo.productId == 11539 {
             
        }
        // how many runs we need to do to make the amount of items the `BlueprintInfo2` makes that we need
        let runsToMake = Int64(ceil(Double(numToMake) / Double(bpInfo.productCount)))
        var inputSums: [Int64: Int64] = [:]
        
        bpInfo.inputMaterials.forEach { input in
            // add the number of input materials to do x runs
            inputSums[input.id] = inputSums[input.id, default: 0] + (runsToMake * input.quantity)
        }
        
        if bpInfo.productId == 11539 {
            print("need \(numToMake) productsPerRun \(bpInfo.productCount) runsToMake \(runsToMake)")
        }
        
        return inputSums
    }
    
    func sumAdjustedInputs(bpInfos: [BPInfo], values: [Int64: Int64], depth: Int) async -> [Int64: Int64] {

        let inputSums: [Int64: Int64] = await withTaskGroup(
            of: [Int64: Int64].self,
            returning: [Int64 : Int64].self
        ) { taskGroup in
            var inputSums: [Int64: Int64] = [:]
            
            for bpInfo in bpInfos {
                guard BlueprintIds.FuelBlocks(rawValue: bpInfo.productId) == nil else { continue }
                taskGroup.addTask {
                    // here we have an input material we want to make.
                    // we want to sum the values of the input materials
                    return await self.sumAdjustedInputs(
                        bpInfo: bpInfo,
                        values: values
                    )
                }
            }
            for await result in taskGroup {
                inputSums.merge(result, uniquingKeysWith: { $0 + $1 })
            }
            
            return inputSums
        }
        
        return inputSums
    }
    
    func getInputBlueprintsForBPInfo(_ value: BPInfo) async -> [BPInfo] {
        let inputMaterials = value.inputMaterials
        
      let blueprintInfos = await getFilteredBlueprintModels(for: inputMaterials)
      return blueprintInfos
    }
    
    func getFilteredBlueprintModels(
      for values: [IdentifiedQuantity]
    ) async -> [BPInfo] {
        let ids = values.map { $0.id }
        .filter { BlueprintIds.FuelBlocks(rawValue: $0) == nil } // filter out things we dont want to make
      
      return await makeBPInfo(for: Set(ids))
    }
    
    /// Returns unique blueprints for the inputs of provided `BlueprintInfo2` array
    func getUniqueInputBlueprints(for blueprints: [BPInfo]) async -> [BPInfo] {
        let result = await withTaskGroup(
            of: [BPInfo].self,
            returning: [BPInfo].self
        ) { taskGroup in
            var returnValues: [Int64: BPInfo] = [:]
            
            blueprints.forEach { bpInfo in
                taskGroup.addTask{
                    return await self.getInputBlueprintsForBPInfo(bpInfo)
                }
            }
            
            for await result in taskGroup {
                result.forEach { value in
                    returnValues[value.productId] = value
                }
                
            }
            return returnValues.map{ $0.value }
        }
        
        return result
    }
    
    func makeDisplayableAsync(from values: [Int64: Int64]) async -> [IdentifiedString] {
        let typeIds = values.map { $0.key }
        let foo = await dbManager.getTypeNames(for: typeIds)
        let results = foo.map { IdentifiedString(id: $0.typeId, value: $0.name) }
        
        return results
    }
    
    func makeDisplayable(from values: [Int64: Int64]) -> [IdentifiedString] {
        let typeIds = values.map { $0.key }
        let foo = dbManager.getTypeNames(for: typeIds)
        let results = foo.map { IdentifiedString(id: $0.typeId, value: $0.name) }
        
        return results
    }
    
    func makeInputGroups(from values: [Int64: Int64]) -> [IPDetailInputGroup2] {
        var returnValues: [IPDetailInputGroup2] = []
        var groupedValues: [Int64: [Int64]] = [:]
        let blueprintIds: [Int64] = values.map { $0.key }
        let inputTypeModels = dbManager.getTypes(for: blueprintIds)
        print("inputTypeModels: \(inputTypeModels.first?.name ?? "none")")
        var names: [Int64: String] = [:]
        let character = dbManager.getCharacters().first!
        var relatedAssets = dbManager.getCharacterAssetsWithTypeForValues(characterID: character.characterId, typeIds: blueprintIds)
        var relatedDict: [Int64: Int64] = [:]
        
        for asset in relatedAssets {
            let existing = relatedDict[asset.asset.typeId, default: 0]
            relatedDict[asset.asset.typeId] = existing + asset.asset.quantity
        }
        
        for name in dbManager.getTypeNames(for: blueprintIds) {
            names[name.typeId] = name.name
        }
        
        // existing count by groupID
        var existingCountDict: [Int64: Int] = [:]
        
        for inputTypeModel in inputTypeModels {
            // get the group for each item and put it in the related group
            let groupID = inputTypeModel.groupID
            //print("for \(inputTypeModel.name) adding \(inputTypeModel.typeId)")
            let existingValues = groupedValues[groupID, default: []]
            groupedValues[groupID] = existingValues + [inputTypeModel.typeId]
            
            let relatedQuantity = relatedDict[inputTypeModel.typeId]
            if let relatedQuantity,
               let inputValue = values[inputTypeModel.typeId],
               relatedQuantity >= inputValue
            {
                existingCountDict[groupID, default: 0] += 1
            }
        }
        
        for group in groupedValues {
            guard let groupName = dbManager.getGroup(for: group.key)?.name else { continue }
            var createdValues: [IPDetailInput1] = []
            
            for typeId in group.value {
                guard let inputValue = values[typeId],
                      let inputName = names[typeId]
                else {
                    print("for \(typeId) inputValue \(values[typeId]) inputName \(names[typeId])")
                    continue
                }
               
                createdValues.append(
                    IPDetailInput1(
                        id: typeId,
                        name: inputName,
                        quantity: inputValue,
                        haveQuantity: relatedDict[typeId, default: 0]
                    )
                )
            }
            createdValues.sort(by: { $0.quantity > $1.quantity })
            returnValues.append(
                IPDetailInputGroup2(
                    groupName: groupName,
                    groupID: group.key,
                    content: createdValues,
                    numHave: existingCountDict[group.key, default: 0]
                )
            )
        }
        returnValues.sort(by: { $0.groupID > $1.groupID })
        return returnValues
    }
}

// helpers
extension IndustryPlannerManager {
    func printNames(_ bpInfos: [BPInfo], values: [Int64: Int64] = [:], depth: Int = 0) {
        let typeIds = bpInfos.map { $0.productId }
        let names = dbManager.getTypeNames(for: typeIds)
        //print("values111 \(values)")
        printNames(names, values: values, depth: depth)
        //print("names \(names)")
        
    }
}


extension IndustryPlannerManager {
    func testThing(typeID: Int64, quantity: Int64) async -> [Int64: Int64] {
        guard let bpInfo = await makeBPInfo(for: typeID) else {
            return [typeID: quantity]
        }
        
        return await nextThing(bpInfos: [bpInfo], values: [typeID: quantity], depth: 0)
    }
    
    func nextThing(bpInfos: [BPInfo], values: [Int64: Int64], depth: Int) async -> [Int64: Int64] {
        print("nextThing \(bpInfos.count)")
        
        var uniqueInputs: Set<Int64> = []
        var returnValues: [Int64: Int64] = [:]
        
        for bpInfo in bpInfos {
            let amountNeeded = values[bpInfo.productId, default: 0]
            guard amountNeeded > 0 else {
                print("no runs for \(bpInfo.blueprintId)")
                continue
            }
            
            let bpMakes = bpInfo.productCount
            let runsNeeded = Int64(ceil(Double(amountNeeded) / Double(bpMakes)))
            
            if bpInfo.productId == 11539 || bpInfo.productId == 16672 {
                print("\(bpInfo.blueprintId)/\(bpInfo.productId) - amountNeeded \(amountNeeded) productsPerRun \(bpInfo.productCount) runsToMake \(runsNeeded)")
            }
            
            for input in bpInfo.inputMaterials {
                if input.id == 16672 {
                    print("\(bpInfo.productId) input count \(input.quantity)")
                }
                returnValues[input.id, default: 0] += runsNeeded * input.quantity
                guard BlueprintIds.FuelBlocks(rawValue: input.id) == nil else {
                    continue
                }
                uniqueInputs.insert(input.id)
            }
        }
        //print("return values \(values)")
        
        printNames(bpInfos, values: values, depth: depth)
        let bpStart = Date()
        let inputBPInfos = await makeBPInfo(for: uniqueInputs)
        print("uniqueinput count \(uniqueInputs.count) bpInfoCount \(bpInfos.count)")
        let bpInfoTook = Date().timeIntervalSince(bpStart)
        //print("Make inputBPInfos took \(bpInfoTook)")
        if !inputBPInfos.isEmpty {
            let start1 = Date()
            let nextLevelSums = await nextThing(
                bpInfos: inputBPInfos,
                values: returnValues,
                depth: depth + 1
            )
            print("nextLevelSums \(nextLevelSums.count)")
            let took = Date().timeIntervalSince(start1)
            //print("sublevel took \(took)")
            print("existing: \(returnValues[16672, default: 0]) new: \(nextLevelSums[16672, default: 0])")
            returnValues.merge(nextLevelSums, uniquingKeysWith: +)
        }
        
        return returnValues
    }
}

extension IndustryPlannerManager {
    func getMissingInputs(blueprintID: Int64) {
        
    }
}
