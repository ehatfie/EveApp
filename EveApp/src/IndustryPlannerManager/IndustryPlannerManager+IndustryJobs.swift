//
//  IndustryPlannerManager+.swift
//  EveApp
//
//  Created by Erik Hatfield on 8/16/24.
//
import Foundation
import ModelLibrary

/*
 struct BlueprintInfo2 {
   let productId: Int64
   let productCount: Int64
   let blueprintModel: BlueprintModel
   let typeModel: TypeModel?
   let inputMaterials: [QuantityTypeModel]
 }
 */
public struct BlueprintIndustryInfo {
  public let blueprintModel: BlueprintModel
  
  public let productId: Int64
  public let productCount: Int64
  public let inputMaterials: [QuantityType]
  
  public let category: String = ""
}

struct IndustryJobPlanStep {
  
}

// related to IndustryJobs related things
extension IndustryPlannerManager {
  
  func createIndustryJobPlan(for blueprintId: Int64) async {
    let characterAssets = await dbManager.getCharacterAssetsForBlueprint(characterID: "", blueprintId: blueprintId)
    guard let blueprintInfo = await self.makeBlueprintIndustryInfo(for: blueprintId) else {
      print("no blueprint info created for \(blueprintId)")
      return
    }
    
    
  }
  
  func createInputs(for blueprintIndustryInfo: BlueprintIndustryInfo, expectedCounts: [Int64: Int]) async {
    let inputMaterials = blueprintIndustryInfo.inputMaterials
    
    guard let numToMake = expectedCounts[blueprintIndustryInfo.productId],
            numToMake > 0
    else {
        print("no count for \(blueprintIndustryInfo.productId)")
        return //[:]
    }
    
    // how many runs we need to do to make the amount of items the `BlueprintInfo2` makes that we need
    let runsToMake = Int(ceil(Double(numToMake) / Double(blueprintIndustryInfo.productCount)))
  }
  
  func makeBlueprintIndustryInfo(for blueprintId: Int64) async -> BlueprintIndustryInfo? {
    guard let blueprintModel = await self.dbManager.getBlueprintModel(
      for: blueprintId
    ) else {
      print("No BlueprintModel for \(blueprintId)")
      return nil
    }
    
    var inputMaterials: [QuantityType] = []
    
    let manufacturing = blueprintModel.activities.manufacturing
    let reactions = blueprintModel.activities.reaction
    
    if !manufacturing.materials.isEmpty {
      inputMaterials = manufacturing.materials.map { QuantityType($0) }
    } else if !reactions.materials.isEmpty {
      inputMaterials = reactions.materials.map { QuantityType($0) }
    } else {
      inputMaterials = []
    }
    
    let product = manufacturing.products.first ?? reactions.products.first!
    
    return BlueprintIndustryInfo(
      blueprintModel: blueprintModel,
      productId: product.typeId,
      productCount: product.quantity,
      inputMaterials: inputMaterials
    )
  }
}
