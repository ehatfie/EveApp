//
//  IndustryPlannerManager+jobs.swift
//  EveApp
//
//  Created by Erik Hatfield on 1/8/24.
//

import Foundation
import TestPackage1

extension IndustryPlannerManager {
  func printNames(for typeIds: [Int64]) {
    let names = dbManager.getTypeNames(for: typeIds).map{$0.name}
    print("type names \(names)")
  }
  
  func sumInputs(
    on inputMaterials: [QuantityTypeModel],
    values: [Int64: Int]
  ) -> [Int64: Int] {
    print("sumInputs")
    let inputMaterialBlueprints: [BlueprintInfo2] = getBlueprintModels(for: inputMaterials)

    var diction: [Int64: BlueprintInfo2] = [:]
    var inputSums: [Int64: Int] = [:]
    
    // Filter out stuff we arent making
    inputMaterialBlueprints.forEach { value in
      guard BlueprintIds.FuelBlocks(rawValue: value.productId) == nil else {
        //inputSums[value.productId] = values[value.productId]
        return
      }
      diction[value.productId] = value
    }
    
    //
    inputMaterials.forEach { material in
      guard let blueprintInfo = diction[material.typeId] else {
        if BlueprintIds.FuelBlocks(rawValue: material.typeId) == nil {
          let newValue = Int(material.quantity) + (inputSums[material.typeId] ?? 0)
          inputSums[material.typeId] = newValue
        }
        
        return
      }
      //let need = values[blueprintInfo.productId]
      //let makes = blueprintInfo.productCount
      // 16673 fernite carbide
      // 46206 fernite carbide reaction formula
      // this values is the wrong one
      let numToMake = Int(ceil(Double(values[blueprintInfo.productId] ?? 1) / Double(blueprintInfo.productCount)))
      //print("\(blueprintInfo.productId) need \(need) \(blueprintInfo.blueprintModel.blueprintTypeID) makes \(makes) num to make \(numToMake)")
      let productsPerRun = blueprintInfo.productCount
      let requiredRuns = Int(ceil(Double(numToMake) / Double(productsPerRun)))
      //print("required runs \(requiredRuns) productsPerRun \(productsPerRun)")
      blueprintInfo.inputMaterials.forEach { inputMaterial in
        let inputCount = Int(inputMaterial.quantity) * requiredRuns
        inputSums[inputMaterial.typeId] = (inputSums[inputMaterial.typeId] ?? 0) + Int(inputCount)
      }
    }
    
    return inputSums
  }
  
  // sums with relation to some runs needed
  func sumInputs3(on blueprintInfo: BlueprintInfo2, values: [Int64: Int]) -> [Int64: Int] {
    //print("sumInputs2")
    let inputMaterials = blueprintInfo.inputMaterials
    let inputMaterialBlueprints: [BlueprintInfo2] = getBlueprintModels(for: inputMaterials)
    
    print("sumInputs3 \(values[blueprintInfo.productId])")

    var diction: [Int64: BlueprintInfo2] = [:]
    var inputSums: [Int64: Int] = [:]
    //filter out fuel blocks
    inputMaterialBlueprints.forEach { value in
      guard BlueprintIds.FuelBlocks(rawValue: value.productId) == nil else {
        // inputSums[value.productId] = values[value.productId]
        return
      }
      diction[value.productId] = value
    }
    
    inputMaterials.forEach { material in
      // make sure
      guard let blueprintInfo = diction[material.typeId] else {
        if BlueprintIds.FuelBlocks(rawValue: material.typeId) == nil {
          let thisMaterialQuantity = Int(material.quantity)
          let existingSums = inputSums[material.typeId] ?? 0
          let numToMake = values[blueprintInfo.productId] ?? 0
          let productsPerRun = blueprintInfo.productCount
          
          let requiredRuns = Int(ceil(Double(numToMake) / Double(productsPerRun)))
          let newValue = (Int(material.quantity) * requiredRuns) + (inputSums[material.typeId] ?? 0)
          print("this material \(thisMaterialQuantity) \(existingSums) newValue: \(newValue) rr \(requiredRuns)")
          inputSums[material.typeId] = newValue //* requiredRuns
        }
        
        return
      }
      let need = values[blueprintInfo.productId]
      let makes = blueprintInfo.productCount
      // 16673 fernite carbide
      // 46206 fernite carbide reaction formula
      // this values is the wrong one
      let numToMake = Int(ceil(Double(values[blueprintInfo.productId] ?? 1) / Double(blueprintInfo.productCount)))
      //print("\(blueprintInfo.productId) need \(need) \(blueprintInfo.blueprintModel.blueprintTypeID) makes \(makes) num to make \(numToMake)")
      let productsPerRun = blueprintInfo.productCount
      let requiredRuns = Int(ceil(Double(numToMake) / Double(productsPerRun)))
      //print("required runs \(requiredRuns) productsPerRun \(productsPerRun)")
      blueprintInfo.inputMaterials.forEach { inputMaterial in
        let inputCount = Int(inputMaterial.quantity) * requiredRuns
        inputSums[inputMaterial.typeId] = (inputSums[inputMaterial.typeId] ?? 0) + Int(inputCount)
      }
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
  
  // this should sum all the inputs for an array of blueprints
  func doThing(for blueprintInfos: [BlueprintInfo2], values: [Int64: Int]) -> [Int64: Int] {
    //print("do thing \(blueprintInfos.map { $0.blueprintModel.blueprintTypeID})")
    //print("do thing values \(values)")
    var inputSums: [Int64: Int] = [:]
    
    blueprintInfos.forEach { blueprintInfo in
      let results = sumInputs(on: blueprintInfo.inputMaterials, values: values)
     // print("for \(blueprintInfo.productId) results \(results)")
      inputSums.merge(results, uniquingKeysWith: { $0 + $1 })
    }
    
    return inputSums
  }

  // this should sum all the inputs for an array of blueprints
  func doThing2(for blueprintInfos: [BlueprintInfo2], values: [Int64: Int]) -> [Int64: Int] {
    print("do thing \(blueprintInfos.map { $0.blueprintModel.blueprintTypeID})")
    print("do thing values \(values)")
    var inputSums: [Int64: Int] = [:]
    
    blueprintInfos.forEach { blueprintInfo in
      //let results = sumInputs2(on: blueprintInfo.inputMaterials, values: values)
      let results = sumInputs3(on: blueprintInfo, values: values)
      print("for \(blueprintInfo.productId) results \(results)")
      inputSums.merge(results, uniquingKeysWith: { $0 + $1 })
    }
    
    return inputSums
  }
  
  func makeJobsForInputSums(values: [Int64: Int]) -> [TestJob] {
    // get blueprints for input materials
    
    let inputMaterialIds = values.keys.map { Int64($0) }
    let inputMaterialBlueprints = getBlueprintModels2(for: inputMaterialIds)
    
    var uniqueBPs: [Int64: BlueprintInfo2] = [:]
    
    inputMaterialBlueprints.forEach { value in
      guard BlueprintIds.FuelBlocks(rawValue: value.productId) == nil else {
        return
      }
      uniqueBPs[value.productId] = value
    }
    
    let jobs: [TestJob] = values.compactMap { key, value -> TestJob? in
      guard let blueprintInfo = uniqueBPs[key] else {
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
    }
    
    return jobs
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

// MARK: - Async
extension IndustryPlannerManager {
  
  func getFilteredBlueprintModels(
    for values: [QuantityTypeModel]
  ) async -> [BlueprintInfo2] {
    let ids = values.map { $0.typeId }
      .filter { BlueprintIds.FuelBlocks(rawValue: $0) == nil } // filter out things we dont want to make
    
    return await getBlueprintModels(for: ids)
  }
  
  func getBlueprintModels(for values: [QuantityTypeModel]) async -> [BlueprintInfo2] {
    return await getBlueprintModels(for: values.map { $0.typeId })
  }
  
  func getBlueprintModels(for values: [Int64]) async -> [BlueprintInfo2] {
    // get the blueprint model for provided itemId
    let materialBps: [BlueprintModel] = values.compactMap { value in
      if let existingBp = cachedBlueprintModels[value] {
        return existingBp
      } else if let bp1 = dbManager.getManufacturingBlueprint(for: value) {
        cachedBlueprintModels[value] = bp1
        return bp1
      } else if let bp2 = dbManager.getReactionBlueprint(for: value) {
        cachedBlueprintModels[value] = bp2
        return bp2
      }
      
      return nil
    }
    
    let blueprintInfos: [BlueprintInfo2] = materialBps.map { matBp in
      var inputMaterials: [QuantityTypeModel]
      
      let manufacturing = matBp.activities.manufacturing
      let reactions = matBp.activities.reaction
      
      if manufacturing.materials.count > 0 {
        inputMaterials = manufacturing.materials
      } else if reactions.materials.count > 0 {
        inputMaterials = reactions.materials
      } else {
        inputMaterials = []
      }
      
      //let typeModel = dbManager.getType(for: matBp.blueprintTypeID)
      //let results = getTypeModels(for: inputMaterials)
      let product = manufacturing.products.first ?? reactions.products.first!
      
      return BlueprintInfo2(
        productId: product.typeId,
        productCount: product.quantity,
        blueprintModel: matBp,
        typeModel: nil, //typeModel,
        inputMaterials: inputMaterials
      )
    }
    return blueprintInfos
  }
  
  /// Returns the `BlueprintModel` for a typeId checking for manufacturing and reaction blueprints
  func getMaterialBlueprint(for typeId: Int64) -> BlueprintModel? {
    if let existingBp = cachedBlueprintModels[typeId] {
      return existingBp
    } else if let bp1 = dbManager.getManufacturingBlueprint(for: typeId) {
      cachedBlueprintModels[typeId] = bp1
      return bp1
    } else if let bp2 = dbManager.getReactionBlueprint(for: typeId) {
      cachedBlueprintModels[typeId] = bp2
      return bp2
    } else {
      return nil
    }
  }
  
  func makeBlueprintInfo(
    for blueprintModel: BlueprintModel
  ) -> BlueprintInfo2 {
    var inputMaterials: [QuantityTypeModel]
    
    let manufacturing = blueprintModel.activities.manufacturing
    let reactions = blueprintModel.activities.reaction
    
    if manufacturing.materials.count > 0 {
      inputMaterials = manufacturing.materials
    } else if reactions.materials.count > 0 {
      inputMaterials = reactions.materials
    } else {
      inputMaterials = []
    }
    
    //let typeModel = dbManager.getType(for: matBp.blueprintTypeID)
    //let results = getTypeModels(for: inputMaterials)
    let product = manufacturing.products.first ?? reactions.products.first!
    
    return BlueprintInfo2(
      productId: product.typeId,
      productCount: product.quantity,
      blueprintModel: blueprintModel,
      typeModel: nil, //typeModel,
      inputMaterials: inputMaterials
    )
  }
  
  /// Takes an array of BlueprintInfo2 and returns a dictionary of the unique values and their productId
  func getUniqueBlueprintInfo(for blueprints: [BlueprintInfo2]) async -> [Int64: BlueprintInfo2] {
    var uniqueBPs: [Int64: BlueprintInfo2] = [:]
    blueprints.forEach { value in
      guard BlueprintIds.FuelBlocks(rawValue: value.productId) == nil else {
        return
      }
      uniqueBPs[value.productId] = value
    }
    return uniqueBPs
  }
  
}
  

class TestJob {
  let quantity: Int64
  let productId: Int64
  let inputs: [QuantityTypeModel]
  let blueprintId: Int64
  let productsPerRun: Int
  let requiredRuns: Int
  
  var numRuns: Int {
    Int(quantity) / productsPerRun + 1
  }
  
  init(
    quantity: Int64,
    productId: Int64,
    inputs: [QuantityTypeModel],
    blueprintId: Int64,
    productsPerRun: Int,
    requiredRuns: Int
  ) {
    self.quantity = quantity
    self.productId = productId
    self.inputs = inputs
    self.blueprintId = blueprintId
    self.productsPerRun = productsPerRun
    self.requiredRuns = requiredRuns
  }
}

struct ShipPlan {
  let jobs: ShipPlanJobs
  let inputs: ShipPlanInputs
  
  static var empty: Self {
    return ShipPlan(
      jobs: .empty,
      inputs: .empty
    )
  }
}

struct ShipPlanInputs {
  let zeroLevelInputs: [Int64: Int]
  let firstLevelInputs: [Int64: Int]
  let secondLevelInputs: [Int64: Int]
  let thirdLevelInputs: [Int64: Int]
  
  static var empty: Self {
    return ShipPlanInputs(
      zeroLevelInputs: [:],
      firstLevelInputs: [:],
      secondLevelInputs: [:],
      thirdLevelInputs: [:])
  }
}

struct ShipPlanJobs {
  let zeroLevelJobs: [TestJob]
  let firstLevelJobs: [TestJob]
  let secondLevelJobs: [TestJob]
  let thirdLevelJobs: [TestJob]
  
  static var empty: Self {
    return ShipPlanJobs(
      zeroLevelJobs: [],
      firstLevelJobs: [],
      secondLevelJobs: [],
      thirdLevelJobs: []
    )
  }
}

// this could be an array or linked list
struct ShipPlanLevels {
  let firstLevel: TestLevel
  let secondLevel: TestLevel
  let thirdLevel: TestLevel
}

struct TestLevel {
  let inputs: [Int64: Int]
  let outputs: [Int64: Int]
}



