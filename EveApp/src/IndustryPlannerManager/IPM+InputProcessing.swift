//
//  IPM+InputProcessing.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/12/24.
//
import Foundation
import ModelLibrary

extension IndustryPlannerManager {
    func makeShipPlan(for blueprintInfo: BlueprintInfo2) async -> ShipPlan {
        print("makeShipPlan() - async")
        let blueprintModel = blueprintInfo.blueprintModel
        let materials: [QuantityTypeModel] = blueprintModel.activities.manufacturing.materials
        
        // sum of inputs for all zero level inputs, resulting in the first level of inputs
        let firstLevelSums = await sumAdjustedInputs(
            blueprintInfo: blueprintInfo,
            values: [blueprintInfo.productId: 1]
        )

        // These are the blueprint models for all inputs to the ship
        let firstLevelBlueprints: [BlueprintInfo2] = await getBlueprintModels(for: materials)
        let secondLevelSums = await sumBlueprintInfoInputs(
            blueprints: firstLevelBlueprints,
            values: firstLevelSums
        )
        
        let secondLevel: [BlueprintInfo2] = await getUniqueInputBlueprints(for: firstLevelBlueprints)
        let thirdLevelSums = await sumBlueprintInfoInputs(
            blueprints: secondLevel,
            values: secondLevelSums
        )
        // we want to get the sum of all second level inputs, this is inputs to the first level of inputs
        let thirdLevelBlueprints = await getUniqueInputBlueprints(for: secondLevel)
        
        let fourthLevelSums = await sumBlueprintInfoInputs(
            blueprints: thirdLevelBlueprints,
            values: thirdLevelSums
        )
        
        print("got sums")
        var bp1: [Int64: BlueprintInfo2] = [:]
        firstLevelBlueprints.forEach { value in
            bp1[value.productId] = value
        }
        
        let zeroLevelJobs = await makeJobsForInputSums(
            inputBlueprints: firstLevelBlueprints,
            inputValues: firstLevelSums
        )
        let firstLevelJobs = await makeJobsForInputSums(
            inputBlueprints: secondLevel,
            inputValues: secondLevelSums
        )
        let secondLevelJobs = await makeJobsForInputSums(
            inputBlueprints: thirdLevelBlueprints,
            inputValues: thirdLevelSums
        )
        print("got jobs")
        return ShipPlan(
            jobs:
                ShipPlanJobs(
                    zeroLevelJobs: zeroLevelJobs,
                    firstLevelJobs: firstLevelJobs,
                    secondLevelJobs: secondLevelJobs,
                    thirdLevelJobs: []
                ),
            inputs:
                ShipPlanInputs(
                    zeroLevelInputs: firstLevelSums,
                    firstLevelInputs: secondLevelSums,
                    secondLevelInputs: thirdLevelSums,
                    thirdLevelInputs: fourthLevelSums
                )
        )
    }
    
    // this function needs to return the sum of whatever is needed to make a number of these blueprints
    func sumBlueprintInfoInputs(
        blueprints: [BlueprintInfo2],
        values: [Int64: Int]
    ) async -> [Int64: Int] {
        let inputSums: [Int64: Int] = await withTaskGroup(
            of: [Int64: Int].self,
            returning: [Int64 : Int].self
        ) { taskGroup in
            var inputSums: [Int64: Int] = [:]
            blueprints.forEach { blueprintInfo in
                taskGroup.addTask {
                    // here we have an input material we want to make.
                    // we want to sum the values of the input materials
                    return await self.sumAdjustedInputs(
                        blueprintInfo: blueprintInfo,
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
        
    /// Sum the input materials needed to make N objects represented by a BlueprintInfo2
    func sumAdjustedInputs(blueprintInfo: BlueprintInfo2, values: [Int64: Int]) async -> [Int64: Int] {
        guard let numToMake = values[blueprintInfo.productId],
                numToMake > 0
        else {
            print("no count for \(blueprintInfo.productId)")
            return [:]
        }
        
        // how many runs we need to do to make the amount of items the `BlueprintInfo2` makes that we need
        let runsToMake = Int(ceil(Double(numToMake) / Double(blueprintInfo.productCount)))
        var inputSums: [Int64: Int] = [:]
        
        blueprintInfo.inputMaterials.forEach { input in
            // add the number of input materials to do x runs
            inputSums[input.typeId] = (inputSums[input.typeId] ?? 0) + (runsToMake * Int(input.quantity))
        }
        return inputSums
    }
    
    /// Returns unique blueprints for the inputs of provided `BlueprintInfo2` array
    func getUniqueInputBlueprints(for blueprints: [BlueprintInfo2]) async -> [BlueprintInfo2] {
        let result = await withTaskGroup(
            of: [BlueprintInfo2].self,
            returning: [BlueprintInfo2].self
        ) { taskGroup in
            var returnValues: [Int64: BlueprintInfo2] = [:]
            
            blueprints.forEach { blueprintInfo in
                taskGroup.addTask{
                    return await self.getInputBlueprintsForBlueprintInfo2(blueprintInfo)
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

}

// MARK: - Job creation
extension IndustryPlannerManager {
    func makeJobsForInputSums(
        inputBlueprints: [BlueprintInfo2],
        inputValues: [Int64: Int]
    ) async -> [TestJob] {
        //these blueprints should be unique but lets make sure
        let uniqueBlueprints = await self.getUniqueBlueprintInfo(for: inputBlueprints)
        
        let jobs: [TestJob] = inputValues.compactMap({ key, value -> TestJob? in
            guard let blueprintInfo = uniqueBlueprints[key] else {
              return nil
            }
            
            let inputQuantity = value
            let productsPerRun = blueprintInfo.productCount
            let requiredRuns = Int(ceil(Double(inputQuantity) / Double(productsPerRun)))
            
            return TestJob(
              quantity: Int64(value),
              productId: blueprintInfo.productId,
              inputs: blueprintInfo.inputMaterials,
              blueprintId: blueprintInfo.blueprintModel.blueprintTypeID,
              productsPerRun: Int(blueprintInfo.productCount),
              requiredRuns: requiredRuns
            )
        })
        
        return jobs
    }
    
}

// Unused stuff
extension IndustryPlannerManager {
    /// Sum the input material for an array of `BlueprintInfo.`Returns a dictionary of itemId and count
    func sumInputs(
        for blueprintInfos: [BlueprintInfo2],
        values: [Int64: Int64]
    ) async -> [Int64: Int64] {
        print("sum inputs on blueprintInfos values:\(values)")
        var inputSums: [Int64: Int64] = [:]
        
        inputSums = await withTaskGroup(
            of: [Int64: Int64].self,
            returning: [Int64: Int64].self
        ) { taskGroup in
            blueprintInfos.forEach { blueprint in
                taskGroup.addTask {
                    return await self.sumValues(on: blueprint.inputMaterials, values: values)
                }
            }
            
            var sums: [Int64: Int64] = [:]
            
            for await result in taskGroup {
                sums.merge(result, uniquingKeysWith: { $0 + $1 })
            }
            
            return sums
        }
        
        return inputSums
    }
    
    // this should only sum the values in the provided array nothing else
    func sumValues(
        on inputMaterials: [QuantityTypeModel],
        values: [Int64: Int64]
    ) async -> [Int64: Int64] {
      print("sumInputsAsync")
      var inputSums: [Int64: Int64] = [:]
      
      inputMaterials.forEach({ value in
          inputSums[value.typeId] = inputSums[value.typeId, default: 0] + value.quantity
      })

      return inputSums
    }
    
    /// Gets an array of all BlueprintInfo for the inputs of a blueprint
    func getBlueprintInfo(
        for blueprints: [BlueprintInfo2]
    ) async -> [(Int64, [BlueprintInfo2])] {
        await withTaskGroup(
            of: (Int64, [BlueprintInfo2]).self,
            returning: [(Int64, [BlueprintInfo2])].self
        ) { taskGroup in
            var returnValues: [(Int64, [BlueprintInfo2])] = []
            blueprints.forEach { value in
                taskGroup.addTask{
                    return (
                        value.productId,
                        await self.getInputBlueprintsForBlueprintInfo2(value)
                    )
                }
            }
            
            for await result in taskGroup {
                returnValues.append(result)
            }
            return returnValues
        }
    }
    
    func getInputBlueprintInfos(for blueprint: BlueprintInfo2) async -> [(Int64, [BlueprintInfo2])] {
        // these are the blueprint models to make the inputs to the provided blueprint
        let blueprintMaterialInputModels = await self.getBlueprintModels(for: blueprint.inputMaterials)
        // we want to get the blueprintInfos for the inputs to each value in this array
        return await getBlueprintInfo(for: blueprintMaterialInputModels)
    }
    
    func getInputBlueprintModels(for typeId: Int64) async -> [BlueprintInfo2] {
        
        return []
    }
    
    // this should sum all the inputs for an array of blueprints
    func doThing2(for blueprintInfos: [BlueprintInfo2], values: [Int64: Int64]) -> [Int64: Int64] {
      print("do thing \(blueprintInfos.map { $0.blueprintModel.blueprintTypeID})")
      print("do thing values \(values)")
      var inputSums: [Int64: Int64] = [:]
      
      blueprintInfos.forEach { blueprintInfo in
        let results = sumInputs(on: blueprintInfo, values: values)
        print("for \(blueprintInfo.productId) results \(results)")
        inputSums.merge(results, uniquingKeysWith: { $0 + $1 })
      }
      
      return inputSums
    }
    
    func getJobs(for inputMaterials: [QuantityTypeModel]) -> [TestJob] {
      let inputMaterialBlueprints: [BlueprintInfo2] = getBlueprintModels(for: inputMaterials)

      var diction: [Int64: BlueprintInfo2] = [:]
      
      inputMaterialBlueprints.forEach { value in
        guard BlueprintIds.FuelBlocks(rawValue: value.productId) == nil else {
          //print("not making \(value.productId)")
          return
        }
        diction[value.productId] = value
      }
      
      let jobs: [TestJob] = inputMaterials.compactMap { material -> TestJob? in
        guard let blueprintInfo = diction[material.typeId] else {
          return nil
        }
        
        let inputQuantity = material.quantity
        let productsPerRun = blueprintInfo.productCount
        let requiredRuns = Int(ceil(Double(inputQuantity) / Double(productsPerRun)))

        return TestJob(
          quantity: material.quantity,
          productId: blueprintInfo.productId,
          inputs: blueprintInfo.inputMaterials,
          blueprintId: blueprintInfo.blueprintModel.blueprintTypeID,
          productsPerRun: Int(productsPerRun),
          requiredRuns: requiredRuns
        )
      }
      
      jobs.forEach { value in
        print("id: \(value.blueprintId) productId: \(value.productId) quantity: \(value.quantity) numRuns: \(value.numRuns)")
      }
      
      return jobs
      //return inputSums
    }
    
  func getInputMaterials(for blueprintModel: BlueprintModel) -> [QuantityTypeModel]  {
    let manufacturing = blueprintModel.activities.manufacturing.materials
    let reaction = blueprintModel.activities.reaction.materials
    if manufacturing.count > 0 {
      return manufacturing
    } else  {
      return reaction
    }
  }
}
