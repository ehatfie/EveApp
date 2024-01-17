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
      
    print("1. inputs for \(typeModel.name) \(firstLevel.map{ $0.typeModel.name })")
    
    let secondLevel: [BlueprintInfo] = getBlueprintInfos(for: firstLevel)
      
//    secondLevel.forEach { value in
//      let names = value.inputMaterials.map { ($0.typeModel.name, $0.quantityTypeModel.quantity) }
//      print("2. inputs for \(value.typeModel.name) \(names)")
//    }
      
    let foo = secondLevel.map { getThingForBlueprintInfo($0)}
    
    
    print()
      
    //makePlan2(for: blueprintInfo)
  }
  
  //
  func makeShipPlan2(for blueprintInfo: BlueprintInfo) {
    // This is a ship blueprint
    let blueprintModel = blueprintInfo.blueprintModel
    let materials: [QuantityTypeModel] = blueprintModel.activities.manufacturing.materials
    
    // These are the blueprint models for all inputs to the ship
    let firstLevel: [BlueprintInfo2] = getBlueprintModels(for: materials)
    // these should be like multiprocessor or shield relay etc
    
    // These are the blueprint models for all inputs to each input to the ship
    let secondLevel = firstLevel.map { ($0.productId, getThingForBlueprintInfo2($0)) }
    // these should be Rolled tungsten alloy
    
    // all the blueprint infos for the materials of a productID blueprint info
    // var diction2: [Int64: [BlueprintInfo2]] = [:]
    let foo = blueprintInfo.inputMaterials.map { $0.quantityTypeModel }
    
    let firstLevelInputSums: [Int64: Int] = doMath(on: foo)
    var secondLevelInputSums: [Int64: Int] = [:]
    
    secondLevel.forEach({ one, two in
      let results = doThing(for: two)
      results.forEach { value in
        let newValue = value.value + (secondLevelInputSums[value.key] ?? 0)
        secondLevelInputSums[value.key] = newValue
      }
    })
    var thirdLevelInputSums: [Int64: Int] = [:]
    
    secondLevel.forEach { one, two in
      // get input blueprints to the inputBlueprint
      let foo = two.flatMap { getThingForBlueprintInfo2($0) }
      // sum inputs for the inputs
      
      let results = doThing(for: foo)
      results.forEach { value in
        let newValue = value.value + (thirdLevelInputSums[value.key] ?? 0)
        thirdLevelInputSums[value.key] = newValue
      }
    }
    
    //let secondLevelInputSums: [Int64: Int] = doMath(
//    print("Second Level")
//    secondLevelInputSums.forEach { key, value in
//      print("key \(key) value \(value)")
//    }
//    
//    print("Third Level")
//    thirdLevelInputSums.forEach { key, value in
//      print("key \(key) value \(value)")
//    }
    
    print()
  }
  
  func doMath(on inputMaterials: [QuantityTypeModel]) -> [Int64: Int] {
    let inputMaterialBlueprints: [BlueprintInfo2] = getBlueprintModels(for: inputMaterials)
//    inputMaterialBlueprints.forEach { value in
//      let names = value.inputMaterials.map { ($0.typeId, $0.quantity) }
//      print("2. inputs for \(value.typeModel.name) \(names)")
//    }
    
    // this contains all the blueprint infos for an item
    var diction: [Int64: BlueprintInfo2] = [:]
    
    inputMaterialBlueprints.forEach { value in
      diction[value.productId] = value
    }
    
    var inputSums: [Int64: Int] = [:]
    
    inputMaterials.forEach { material in
      guard let blueprintInfo = diction[material.typeId] else {
        inputSums[material.typeId] = Int(material.quantity) + (inputSums[material.typeId] ?? 0)
        return
      }
      
      let inputQuantity = material.quantity
      let productsPerRun = blueprintInfo.productCount
      let requiredRuns = Int(ceil(Double(inputQuantity) / Double(productsPerRun)))
      
      blueprintInfo.inputMaterials.forEach { inputMaterial in
        let inputCount = Int(inputMaterial.quantity) * requiredRuns
        inputSums[inputMaterial.typeId] = (inputSums[inputMaterial.typeId] ?? 0) + Int(inputCount)
      }
    }
    
    return inputSums
  }
  
  // this should sum all the inputs for an array of blueprints
  func doThing(for blueprintInfos: [BlueprintInfo2]) -> [Int64: Int] {
    //print("do thing")
    var inputSums: [Int64: Int] = [:]
    
    blueprintInfos.forEach { blueprintInfo in
      let results = doMath(on: blueprintInfo.inputMaterials)
        //print("got results \(results)")
      results.forEach { value in
        inputSums[value.key] = value.value + (inputSums[value.key] ?? 0)
      }
    }
    
    return inputSums
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
    
  func getJobs(for blueprintInfo: BlueprintInfo) {
    let blueprintModel = blueprintInfo.blueprintModel
    let typeModel = blueprintInfo.typeModel
    let materials = blueprintModel.activities.manufacturing.materials
    
    let foo: [TestJob] = materials.compactMap { value -> TestJob? in
      guard let bp = dbManager.getBlueprint(for: value.typeId) else {
        return nil
      }
      
      let manufacturing = bp.activities.manufacturing
      let reactions = bp.activities.reaction
      
      var productsPerRun = 0
      if let value = manufacturing.products.first {
        productsPerRun = Int(value.quantity)
      } else if let value = reactions.products.first {
        productsPerRun = Int(value.quantity)
      }
      
      return TestJob(
        quantity: Int(value.quantity),
        productId: value.typeId,
        inputs: materials,
        blueprintId: blueprintModel.blueprintTypeID,
        productsPerRun: productsPerRun
      )
    }
  }
  
}

class TestJob {
  let quantity: Int
  let productId: Int64
  let inputs: [QuantityTypeModel]
  let blueprintId: Int64
  let productsPerRun: Int
  
  var numRuns: Int {
    quantity / productsPerRun + 1
  }
  
  init(quantity: Int, productId: Int64, inputs: [QuantityTypeModel], blueprintId: Int64, productsPerRun: Int) {
    self.quantity = quantity
    self.productId = productId
    self.inputs = inputs
    self.blueprintId = blueprintId
    self.productsPerRun = productsPerRun
  }
}
