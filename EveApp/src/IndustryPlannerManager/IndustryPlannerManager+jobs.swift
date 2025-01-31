//
//  IndustryPlannerManager+jobs.swift
//  EveApp
//
//  Created by Erik Hatfield on 1/8/24.
//

import Foundation
import ModelLibrary

extension IndustryPlannerManager {
  func printNames(for typeIds: [Int64]) {
    let names = dbManager.getTypeNames(for: typeIds).map{$0.name}
    print("type names \(names)")
  }
  
  /// - Parameters
  ///  - blueprintInfo: The blueprint to sum inputs on
  ///  - values: Expected count for an input value. This contains a number of objects represented by the blueprintInfo
  /// - Returns: Dictionary of the sum of the inputs
  func sumInputs(
    on blueprintInfo: BlueprintInfo2,
    values: [Int64: Int64]
  ) -> [Int64: Int64] {
    let inputMaterials = blueprintInfo.inputMaterials
    let inputMaterialBlueprints: [BlueprintInfo2] = getBlueprintModels(for: inputMaterials)
    
    print("sumInputs \(values[blueprintInfo.productId, default: 0])")

    var diction: [Int64: BlueprintInfo2] = [:]
    var inputSums: [Int64: Int64] = [:]
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
          let existingSums = inputSums[material.typeId, default: 0]
          let numToMake = values[blueprintInfo.productId, default: 0]
          let productsPerRun = blueprintInfo.productCount
          
          let requiredRuns = Int64(ceil(Double(numToMake) / Double(productsPerRun)))
          let newValue = (material.quantity * requiredRuns) + inputSums[material.typeId, default: 0]
          print("this material \(thisMaterialQuantity) \(existingSums) newValue: \(newValue) rr \(requiredRuns)")
          inputSums[material.typeId] = newValue //* requiredRuns
        }
        
        return
      }
      
      let needToMake = Double(values[blueprintInfo.productId, default: 1])
      let madePerRun = Double(blueprintInfo.productCount)
      // 16673 fernite carbide
      // 46206 fernite carbide reaction formula
      // this values is the wrong one
      let requiredRuns = Int64(
        ceil(
          needToMake / madePerRun
        )
      )
      
      // determine the number of inputs we need based on the required runs
      blueprintInfo.inputMaterials.forEach { inputMaterial in
        let inputCount: Int64 = inputMaterial.quantity * requiredRuns
        inputSums[inputMaterial.typeId] = inputSums[inputMaterial.typeId, default: 0] + inputCount
      }
    }
    
    return inputSums
  }
  
  // This is the one we should use for most things
  /// Takes provided typeID:quantity dictionary and creates the jobs needed to make the provided quantity of the typeID
  func makeJobsForInputSums(inputs: [Int64: Int64]) -> [TestJob] {
    // get blueprints for input materials
    let inputMaterialIds = inputs.keys.map { $0 }
    let inputMaterialBlueprints = getBlueprintModels2(for: inputMaterialIds)
    
    var uniqueBPs: [Int64: BlueprintInfo2] = [:]
    
    inputMaterialBlueprints.forEach { value in
      guard BlueprintIds.FuelBlocks(rawValue: value.productId) == nil else {
        return
      }
      uniqueBPs[value.productId] = value
    }
    
    let jobs: [TestJob] = inputs.compactMap { key, value -> TestJob? in
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
  
  func makeDisplayableJobsForInputSums(inputs: [Int64: Int64]) async -> [DisplayableJob] {
    let jobs = makeJobsForInputSums(inputs: inputs)
    
    var jobsDict: [Int64: TestJob] = [:]
    
    for job in jobs {
      jobsDict[job.blueprintId] = job
    }
    
    let idSet: Set<Int64> = Set(jobsDict.keys)
    //let names = await dbManager.getTypeNames(for: Array(idSet))
    let names1: [(Int64, String)] = (try? await dbManager.getBlueprintNames(Array(idSet))) ?? []
    
    let displayableJobs: [DisplayableJob] = names1.compactMap { value -> DisplayableJob? in
      guard let existingJob = jobsDict[value.0] else { return nil }
      //print("got name \(value.1)")
      return DisplayableJob(existingJob, productName: "", blueprintName: value.1)
    }
    
    return displayableJobs //jobs.map(\.init)
  }
  
  func makeDisplayableJobsFor(
    blueprintID: Int64,
    relatedAssets: [Int64: Int64]
  ) async -> [DisplayableJob] {
    guard let blueprintModel = await dbManager.getBlueprintModel(for: blueprintID) else { return [] }
    return []
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
  let inputs: [IdentifiedQuantity]
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
    self.inputs = inputs.map { IdentifiedQuantity($0)}
    self.blueprintId = blueprintId
    self.productsPerRun = productsPerRun
    self.requiredRuns = requiredRuns
  }
  
  init(
    quantity: Int64,
    productId: Int64,
    inputs: [IdentifiedQuantity],
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

struct DisplayableJob: Identifiable {
  var id: Int64 {
    productId
  }
  let quantity: Int64
  let productId: Int64
  let blueprintId: Int64
  let productName: String
  let blueprintName: String
  let inputs: [IdentifiedQuantity]
  let requiredRuns: Int
  
  init(_ data: TestJob, productName: String, blueprintName: String) {
    self.quantity = data.quantity
    self.productId = data.productId
    self.productName = productName
    self.blueprintName = blueprintName
    self.inputs = data.inputs
    self.requiredRuns = data.requiredRuns
    self.blueprintId = data.blueprintId
  }
}

struct DisplayableQuantity {
  let id: Int64
  let quantity: Int64
  let name: String
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



