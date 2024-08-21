//
//  IndustryPlannerManager+.swift
//  EveApp
//
//  Created by Erik Hatfield on 8/16/24.
//

// related to IndustryJobs related things
extension IndustryPlannerManager {
  
  func createIndustryJobPlan(for blueprintId: Int64) async {
    guard let blueprintModel = await self.dbManager.getBlueprintModel(
      for: blueprintId
    ) else {
      print("No BlueprintModel for \(blueprintId)")
      return
    }
    
    let blueprintInfo = self.makeBlueprintInfo(for: blueprintModel)
    
    //print("got blueprintInfo \(blueprintInfo)")
  }
  
}
