//
//  IndustryPlannerManager+jobs.swift
//  EveApp
//
//  Created by Erik Hatfield on 1/8/24.
//

import Foundation

extension IndustryPlannerManager {
  // This could work but we dont need to fetch TypeModel for each thing, dont need ItemQuantityInfo.
  func makeShipPlan(for blueprintInfo: BlueprintInfo) {
    let blueprintModel = blueprintInfo.blueprintModel
    let typeModel = blueprintInfo.typeModel
    let materials = blueprintModel.activities.manufacturing.materials
    
    let firstLevel: [ItemQuantityInfo] = getTypeModels(for: materials)
    
    print()
      
    //makePlan2(for: blueprintInfo)
  }
  
  //
  func makeShipPlan2(for blueprintInfo: BlueprintInfo) -> ShipPlan {
    print("makeShipPlan2()")
    // This is a ship blueprint
    let blueprintModel = blueprintInfo.blueprintModel
    let materials: [QuantityTypeModel] = blueprintModel.activities.manufacturing.materials
    
    var start = Date()
    var zeroLevelInputs: [Int64: Int] = [:]
    
    blueprintInfo.inputMaterials.forEach { value in
      zeroLevelInputs[value.quantityTypeModel.typeId] = Int(value.quantityTypeModel.quantity)
    }
    // These are the blueprint models for all inputs to the ship
    let firstLevel: [BlueprintInfo2] = getBlueprintModels(for: materials)
    let firstLevelTook = start.timeIntervalSinceNow * -1
    print("first level took \(firstLevelTook) to fetch")
    
    start = Date()
    // this might should contain a count of number needed
    let secondLevel: [(Int64, [BlueprintInfo2])] = firstLevel.map { ($0.productId, getThingForBlueprintInfo2($0)) }
    print("second level")
    let secondLevelTook = start.timeIntervalSinceNow * -1
    print("second level took \(secondLevelTook) to fetch")
    // these should be Rolled tungsten alloy
    
    // all the blueprint infos for the materials of a productID blueprint info
    // var diction2: [Int64: [BlueprintInfo2]] = [:]
    let zeroLevelInputModels = blueprintInfo.inputMaterials.map { $0.quantityTypeModel }
    
    start = Date()
    // sum inputs for all zero level inputs, resulting in the first level of inputs
    let firstLevelInputSums: [Int64: Int] = sumInputs(on: zeroLevelInputModels, values: zeroLevelInputs)
    let firstLevelSumTook = start.timeIntervalSinceNow * -1
    print("first level sum took \(firstLevelSumTook)")
    

    var secondLevelInputSums: [Int64: Int] = [:]
    
    start = Date()
    secondLevelInputSums = doThing(for: firstLevel, values: firstLevelInputSums)
    
    let secondLevelSumsTook = start.timeIntervalSinceNow * -1
    print("second level sums took \(secondLevelSumsTook)")
    
    var thirdLevelInputSums: [Int64: Int] = [:]
    
    start = Date()
    let thirdLevel = secondLevel.flatMap { one, two in
      return two.flatMap { getThingForBlueprintInfo2($0) }
    }
    
    var thirdLevelInputBps: [Int64: BlueprintInfo2] = [:]
    
    thirdLevel.forEach { value in
      thirdLevelInputBps[value.productId] = value
    }
    
    
    thirdLevelInputSums = doThing2(for: thirdLevelInputBps.map { $0.value }, values: secondLevelInputSums)
//    secondLevel.forEach { one, two in
//      // this doesnt work because we might pull the same blueprint info multiple times
//      // for inputs that would be covered by for example one reaction run is being
//      // counted as multiple runs
//      let thirdLevel = two.flatMap { getThingForBlueprintInfo2($0) }
//      
//      let results = doThing2(for: thirdLevel, values: secondLevelInputSums)
//      thirdLevelInputSums.merge(results, uniquingKeysWith: { $0 + $1 })
//      print("thirdLevelInputSums \(thirdLevelInputSums[16644])")
//    }
    let thirdLevelSumTook = start.timeIntervalSinceNow * -1
    print("third level sums took \(thirdLevelSumTook)")
    
    print()
    
    let zeroLevelJobs: [TestJob] = makeJobsForInputSums(values: zeroLevelInputs)
    let firstLevelJobs: [TestJob] = makeJobsForInputSums(values: firstLevelInputSums)
    let secondLevelJobs: [TestJob] = makeJobsForInputSums(values: secondLevelInputSums)
    let thirdLevelJobs: [TestJob] = makeJobsForInputSums(values: thirdLevelInputSums)
    
    let shipPlanJobs = ShipPlanJobs(
      zeroLevelJobs: zeroLevelJobs,
      firstLevelJobs: firstLevelJobs,
      secondLevelJobs: secondLevelJobs,
      thirdLevelJobs: thirdLevelJobs
    )
    
    let shipPlanInputs = ShipPlanInputs(
      zeroLevelInputs: zeroLevelInputs,
      firstLevelInputs: firstLevelInputSums,
      secondLevelInputs: secondLevelInputSums,
      thirdLevelInputs: thirdLevelInputSums
    )
    
    return ShipPlan(jobs: shipPlanJobs, inputs: shipPlanInputs)
  }
  
  func printNames(for typeIds: [Int64]) {
    let names = dbManager.getTypeNames(for: typeIds).map{$0.name}
    print("type names \(names)")
  }
  
  func sumInputs(on inputMaterials: [QuantityTypeModel], values: [Int64: Int]) -> [Int64: Int] {
    print("sumInputs")
    let inputMaterialBlueprints: [BlueprintInfo2] = getBlueprintModels(for: inputMaterials)

    var diction: [Int64: BlueprintInfo2] = [:]
    var inputSums: [Int64: Int] = [:]
    
    inputMaterialBlueprints.forEach { value in
      guard BlueprintIds.FuelBlocks(rawValue: value.productId) == nil else {
        //inputSums[value.productId] = values[value.productId]
        return
      }
      diction[value.productId] = value
    }
    
    inputMaterials.forEach { material in
      guard let blueprintInfo = diction[material.typeId] else {
        if BlueprintIds.FuelBlocks(rawValue: material.typeId) == nil {
          let newValue = Int(material.quantity) + (inputSums[material.typeId] ?? 0)
          inputSums[material.typeId] = newValue
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
  
  func sumInputs2(on inputMaterials: [QuantityTypeModel], values: [Int64: Int]) -> [Int64: Int] {
    //print("sumInputs2")
    let inputMaterialBlueprints: [BlueprintInfo2] = getBlueprintModels(for: inputMaterials)

    var diction: [Int64: BlueprintInfo2] = [:]
    var inputSums: [Int64: Int] = [:]
    
    inputMaterialBlueprints.forEach { value in
      guard BlueprintIds.FuelBlocks(rawValue: value.productId) == nil else {
        // inputSums[value.productId] = values[value.productId]
        return
      }
      diction[value.productId] = value
    }
    
    inputMaterials.forEach { material in
      
      guard let blueprintInfo = diction[material.typeId] else {
        if BlueprintIds.FuelBlocks(rawValue: material.typeId) == nil {
          let thisMaterialQuantity = Int(material.quantity)
          let existingSums = inputSums[material.typeId] ?? 0
          
          let newValue = Int(material.quantity) + (inputSums[material.typeId] ?? 0)
          print("this material \(thisMaterialQuantity) \(existingSums) newValue: \(newValue)")
          inputSums[material.typeId] = newValue
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
  
  func sumInputs3(on blueprintInfo: BlueprintInfo2, values: [Int64: Int]) -> [Int64: Int] {
    //print("sumInputs2")
    let inputMaterials = blueprintInfo.inputMaterials
    let inputMaterialBlueprints: [BlueprintInfo2] = getBlueprintModels(for: inputMaterials)
    
    print("sumInputs3 \(values[blueprintInfo.productId])")

    var diction: [Int64: BlueprintInfo2] = [:]
    var inputSums: [Int64: Int] = [:]
    
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
  
  func doJobThing(for blueprintInfos: [BlueprintInfo2]) -> [TestJob] {
  
    return blueprintInfos.flatMap { blueprintInfo in
      return getJobs(for: blueprintInfo.inputMaterials)
    }
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



