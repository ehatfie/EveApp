//
//  IndustryPlannerManager.swift
//  EveApp
//
//  Created by Erik Hatfield on 1/2/24.
//

import Foundation
import Fluent
import TestPackage1

class IndustryPlan {
  // type of plan
  // jobs to run
  // material inputs
  // material outputs
}

class IndustryPlannerManager {
  let dbManager: DBManager
  
  var cachedBlueprintModels: [Int64: BlueprintModel] = [:]
  
  init(dbManager: DBManager) {
    self.dbManager = dbManager
    
    start()
  }
  
  func start() {
    // need the blueprint
    // get materials
    // get jobs for materials
    // get jobs to run for materials
  }
  
  func makePlan(for blueprintModel: BlueprintModel) async -> ShipPlan {
    print("make plan for blueprintModel")
    let blueprintActivities = blueprintModel.activities
    guard let productTypeId = blueprintActivities.manufacturing.products.first?.typeId else { return .empty }
    let productTypeModel = await dbManager.getType(for: productTypeId)!
    
    // determine what thing we are making
    let categoryModel = dbManager.getCategory(groupId: productTypeModel.groupID)
    let categoryType = CategoryTypes(rawValue: categoryModel.categoryId)
    
    let blueprintInfo: BlueprintInfo2 = makeBlueprintInfo(for: blueprintModel)
    switch categoryType {
    case .ship: return await makeShipPlan(for: blueprintInfo)//makeShipPlan2(for: blueprintInfo)
    default: return .empty
    }
  
  }
  
  func getThingForBlueprintInfo(_ value: BlueprintInfo) -> [BlueprintInfo] {
    let inputMaterials = value.inputMaterials
    let blueprintInfos = getBlueprintInfos(for: inputMaterials)

    return blueprintInfos
  }
  
  func getInputBlueprintsForBlueprintInfo2(
    _ value: BlueprintInfo2
  ) -> [BlueprintInfo2] {
    let inputMaterials = value.inputMaterials
    let blueprintInfos = getBlueprintModels(for: inputMaterials)
    return blueprintInfos
  }
  
  func getInputBlueprintsForBlueprintInfo2(_ value: BlueprintInfo2) async -> [BlueprintInfo2] {
    let inputMaterials = value.inputMaterials
    let blueprintInfos = await getFilteredBlueprintModels(for: inputMaterials)
    return blueprintInfos
  }
  
  func getBlueprintInfos(for values: [ItemQuantityInfo]) -> [BlueprintInfo] {
    let materialBps = values.compactMap { value in
      if let bp1 = dbManager.getManufacturingBlueprint(for:value.typeModel.typeId) {
        return bp1
      } else if let bp2 = dbManager.getReactionBlueprint(for:value.typeModel.typeId) {
        return bp2
      }
      
      return nil
    }
    
    let blueprintInfos: [BlueprintInfo] = materialBps.map { matBp in
      var inputMaterials: [QuantityTypeModel]
      
      if matBp.activities.manufacturing.materials.count > 0 {
        inputMaterials = matBp.activities.manufacturing.materials
      } else if matBp.activities.reaction.materials.count > 0 {
        inputMaterials = matBp.activities.reaction.materials
      } else {
        inputMaterials = []
      }
      
      let typeModel = dbManager.getType(for: matBp.blueprintTypeID)
      let results = getTypeModels(for: inputMaterials)
      
      return BlueprintInfo(blueprintModel: matBp, typeModel: typeModel, inputMaterials: results)
    }
    return blueprintInfos
  }
  
  func getBlueprintModels(for values: [QuantityTypeModel]) -> [BlueprintInfo2] {
    let ids = values.map { $0.typeId }
      .filter { BlueprintIds.FuelBlocks(rawValue: $0) == nil }
    return getBlueprintModels2(for: ids)
  }
  
  func getBlueprintModels2(for values: [Int64]) -> [BlueprintInfo2] {
    // get the blueprint model for provided inputs
    let materialBps = values.compactMap { value in
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
  
  func getTypeModels(for items: [QuantityTypeModel]) -> [ItemQuantityInfo] {
    let results = items.compactMap { quantityTypeModel in
      let typeModel = try! TypeModel.query(on: dbManager.database)
        .filter(\.$typeId == quantityTypeModel.typeId)
        .first()
        .wait()!
      
      return ItemQuantityInfo(typeModel: typeModel, quantityTypeModel: quantityTypeModel)
    }
    return results
  }
}

// Depth first versions?
extension IndustryPlannerManager {
  func makePlan3(for blueprintModel: BlueprintModel) -> IndustryPlanJob? {
    let typeModel = dbManager.getType(for: blueprintModel.blueprintTypeID)
    let blueprintActivities = blueprintModel.activities
    
    guard let productTypeId = blueprintActivities.manufacturing.products.first?.typeId else { return nil }
    
    let productTypeModel = DataManager.shared
      .dbManager!.getType(for: productTypeId)
    
    let blueprintInfo = BlueprintInfo(blueprintModel: blueprintModel, typeModel: typeModel, inputMaterials: [])
    
    return makePlan2(for: blueprintInfo)
  }
  
  func makePlan2(for blueprintInfo: BlueprintInfo) -> IndustryPlanJob {
    let blueprintModel = blueprintInfo.blueprintModel
    let typeModel = blueprintInfo.typeModel
    let materials = blueprintModel.activities.manufacturing.materials
    
    let inputs: [ItemQuantityInfo] = getTypeModels(for: materials)
    
    print("Make Plan 2")
    let bpInputs: [InputMaterialInfo] = []
//    inputs.map { value in
//      doThing1(for: value)
//    }
//    
    
    let industryPlanJob = IndustryPlanJob(
      blueprintModel: blueprintModel,
      blueprintTypeModel: typeModel,
      quantity: 0,
      jobsToRun: 0,
      inputMaterials: bpInputs)
    // get the BlueprintInfo objects for all material inputs of the original blueprintInfo
    //let inputMaterialBlueprintInfos: [BlueprintInfo] = getThingForBlueprintInfo(blueprintInfo1)
    return industryPlanJob
  }
  
  func doThing1(for thing: ItemQuantityInfo, level: Int = 0) -> InputMaterialInfo {
    var prefix = ""
    if level == 1 {
      prefix = "- "
    } else if level == 2 {
      prefix = "-- "
    } else if level == 3 {
      prefix = "--- "
    } else if level == 4 {
      prefix = "---- "
    } else if level == 5 {
      prefix = "----- "
    }
    
    //print("\(prefix)\(thing.typeModel.name)")
    guard let materialBp: BlueprintModel = getMaterialBp(for: thing.typeModel.typeId) else {
      return InputMaterialInfo(
        typeModel: thing.typeModel,
        quantity: Int(thing.quantityTypeModel.quantity),
        blueprintModel: nil,
        inputs: []
      )
    }
    
    let bpTypeModel: TypeModel = dbManager.getType1(for: materialBp.blueprintTypeID)
    
    let materialBpMaterials: [QuantityTypeModel]
    
    let manufacturingMaterials = materialBp.activities.manufacturing.materials
    let reactionMaterials = materialBp.activities.reaction.materials
    
    if manufacturingMaterials.count > reactionMaterials.count {
      materialBpMaterials = manufacturingMaterials
    } else {
      materialBpMaterials = reactionMaterials
    }
    
    let inputs: [ItemQuantityInfo] = getTypeModels(for: materialBpMaterials)
    
    let inputs1 = inputs.map { value in
      doThing1(for: value, level: level + 1)
    }
    
    return InputMaterialInfo(
      typeModel: thing.typeModel,
      quantity: Int(thing.quantityTypeModel.quantity),
      blueprintModel: BlueprintInfo(
        blueprintModel: materialBp,
        typeModel: bpTypeModel,
        inputMaterials: inputs
      ),
      inputs: inputs1
    )
    //let results = getTypeModels(for: inputMaterials)
  }
  
  func getMaterialBp(for typeId: Int64) -> BlueprintModel? {
    if let bp1 = dbManager.getManufacturingBlueprint(for: typeId) {
      return bp1
    } else if let bp2 = dbManager.getReactionBlueprint(for: typeId) {
      return bp2
    }
    return nil
  }
  
}

// has all the jobs for a certain material level (step)
struct IndustryPlanStep {
  let jobs: [String]
}

struct ItemQuantityInfo {
  let typeModel: TypeModel
  let quantityTypeModel: QuantityTypeModel
}

struct BlueprintInfo {
  let blueprintModel: BlueprintModel
  let typeModel: TypeModel
  let inputMaterials: [ItemQuantityInfo]
}

struct BlueprintInfo2 {
  let productId: Int64
  let productCount: Int64
  let blueprintModel: BlueprintModel
  let typeModel: TypeModel?
  let inputMaterials: [QuantityTypeModel]
}

struct InputMaterialInfo {
  let typeModel: TypeModel
  let quantity: Int
  let blueprintModel: BlueprintInfo?
  let inputs: [InputMaterialInfo]
}

// what you need to do to make a material
struct IndustryPlanJob {
  let blueprintModel: BlueprintModel // blueprint for the material
  let blueprintTypeModel: TypeModel // type model for the blueprint
  let quantity: Int // amount you need to do
  let jobsToRun: Int
  let inputMaterials: [InputMaterialInfo]
  // inputs
  // outputs
}
/*
 we know the industry levels of an item
 
 (groups)
 t0
  promethium - 427
 
 
 ferrofluid: 428
 ferrogel: 429
 
 Ferrofluid Reaction: 436
 ferrofluid reaction formula: 1888
 ferrogel reaction formula: 1888
 rolled tungsten alloy reaction formula: 1888
 
 groups
 - 333: construction components (advanced components)
 - 429: composite (composite reactions)
 
 
 moon materials -> simple (Intermediate) reactions -> composite reactions ->
 construction (Advanced) components -> End product
 
 jobs:
 - simple reactions (t0 -> t1)
 - composite reactions (t1 -> t2)
 - advanced components (t2 -> t3)
 - other inputs
 - final job
 
 climb down:
 - start blueprint
 - advanced components + other (ex: ships)
 - composite reactions
 - simple reactions
 
 
 
 
 */
protocol GroupEnum: RawRepresentable where RawValue == Int64 { }

enum IndustryGroup: Int64, CaseIterable, GroupEnum {
  enum Reactions: Int64, CaseIterable, GroupEnum {
    //case compositeReactions = 429
    case simpleReactions = 436
    case complexReactions = 484
  }
  
  enum Materials: Int64, CaseIterable, GroupEnum {
    case constructionComponents = 334
    case intermediateMaterials = 428
    case moonMaterials = 427
    case composites = 429
  }

  case compositeReactionsFormula = 1888
}

enum BlueprintGroups: Int64 {
  case frigateBlueprint = 105
  case cruiserBlueprint = 106
  case battleshipBlueprint = 107
  case destroyerBlueprint = 487
  case battleCruiserBlueprint = 489
}

enum CategoryTypes: Int64 {
  case material = 4
  case accessories = 5
  case ship = 6
  case reaction = 24
  case decryptors = 35
}

enum IndustryPlanStepTypes {
  case some
}
