//
//  IndyTool.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/24/24.
//
import Foundation
import ModelLibrary

struct IndyJob {
  
}

class IndyTool {
  let dbManager: DBManager
  var characterID: String? = nil
  var relatedAssets: [Int64: Int64] = [:]
  
  init(dbManager: DBManager) {
    self.dbManager = dbManager
    characterID = dbManager.getCharacters().first?.characterId
  }
  
  func getMissingInputs(values: [Int64: Int64]) async -> [Int64: Int64] {
    
    guard !values.isEmpty else {
      return [:]
    }
    //print("getMissingInputs bulk \(values.keys)")
    let result = await withTaskGroup(
      of: [Int64: Int64].self,
      returning: [Int64: Int64].self
    ) { taskGroup in
      for value in values {
        taskGroup.addTask {
          return await self.getMissingInputs(blueprintID: value.key, quantity: value.value)
        }
      }
      var returnValues: [Int64: Int64] = [:]
      
      for await value in taskGroup {
        //print("merging \(value)")
        returnValues.merge(value, uniquingKeysWith: +)
      }
      
      return returnValues
    }
    return result
  }
  
  func getMissingInputs(
    blueprintID: Int64,
    quantity: Int64
  ) async -> [Int64: Int64] {
    if blueprintID == 33361 || blueprintID == 40 {
      print("getMissingInputs \(blueprintID) \(quantity)")
    }
    
    guard let bpInfo = await makeBPInfo(for: blueprintID) else {
      //print("cant make BPInfo for \(blueprintID)")
      return [:]
    }
    if blueprintID == 33361 {
      print("found \(bpInfo.blueprintId) making \(bpInfo.productId)")
    }
   
    let missingInputs = await findMissingInputs(
      bpInfos: [bpInfo],
      values: [bpInfo.productId: quantity],
      depth: 0
    )
    if blueprintID == 33361, missingInputs[blueprintID] != nil {
      print("Shouldnt be missing this?")
    }
    return missingInputs
  }
  
  func findMissingInputs(
    bpInfos: [BPInfo],
    values: [Int64: Int64],
    depth: Int
  ) async -> [Int64: Int64] {
    var returnValues: [Int64: Int64] = [:]
    let inputProducts = bpInfos.flatMap { $0.inputMaterials.map { $0.id }}
    if inputProducts.contains(where: { $0 == 40 }) {
      print("got megacyte")
    }
    await loadCharacterAssets(for: inputProducts)
    //let assets = dbManager.getCharacterAssetsForValues(characterID: 0, typeIds: inputProducts)
    for bpInfo in bpInfos {
      let parentAmountNeeded = values[bpInfo.productId, default: 0]
      let productsPerRun = bpInfo.productCount
      let runsNeeded = Int64(ceil(Double(parentAmountNeeded) / Double(productsPerRun)))
      
      for input in bpInfo.inputMaterials {
        let amountNeeded = input.quantity * runsNeeded
        
        guard amountNeeded > 0 else {
          print("no runs for \(bpInfo.blueprintId)")
          continue
        }

        if input.id == 40 {
          print("\(bpInfo.productId) input count \(input.quantity)")
        }

        //returnValues[input.id, default: 0] += runsNeeded * input.quantity
        guard BlueprintIds.FuelBlocks(rawValue: input.id) == nil else {
          continue
        }
        let matchingAssetQuantity = relatedAssets[input.id, default: 0]
        let amountMissing = max(0, amountNeeded - matchingAssetQuantity)
        
        guard amountMissing > 0 else {
          //print("not missing \(input.id)")
          continue
        }
//        print("Adding missing input \(input.id) matching \(matchingAssetQuantity) needed \(amountNeeded) missing \(amountMissing)")
        returnValues[input.id] = amountMissing
      }
    }
    
    return await
      getMissingInputs(values: returnValues).merging(returnValues, uniquingKeysWith: +)
  }
  
  func makeJobs(for values: [Int64: Int64]) -> [IndyJob] {
    return []
  }
  
  func loadCharacterAssets(for typeIds: [Int64]) async {
    guard let characterID else {
      print("no character ID")
      return
    }
    let fetchedIds: Set<Int64> = Set(relatedAssets.map { $0.key })
    let missingIds: Set<Int64> = Set(typeIds).subtracting(fetchedIds)
    let assets = await dbManager.getCharacterAssetsForValues(
      characterID: characterID,
      typeIds: Array(missingIds)
    )
    for asset in assets {
      relatedAssets[asset.typeId] = asset.quantity
    }
  }
  
  func makeBPInfos(for blueprintIds: [Int64]) async -> [BPInfo] {
    var returnValues = [BPInfo]()
    
    for blueprintId in blueprintIds {
      guard let bpInfo = await makeBPInfo(for: blueprintId) else {
        continue
      }
      returnValues.append(bpInfo)
    }
    
    return returnValues
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
}

// MARK: - Jobs

extension IndyTool {
  func makeDisplayableJobsForInputSums(inputs: [Int64: Int64]) async -> [DisplayableJob] {
    //print("makeDisplayableJobsForInputSums \(self.relatedAssets)")
    let jobs = await makeJobsForInputSums(inputs: inputs, assets: self.relatedAssets)
    
    var jobsDict: [Int64: TestJob] = [:]
    
    for job in jobs {
      jobsDict[job.blueprintId] = job
    }
    
    let idSet: Set<Int64> = Set(jobsDict.keys)
    //let names = await dbManager.getTypeNames(for: Array(idSet))
    let names1: [(Int64, String)] = (try? await dbManager.getBlueprintNames(Array(idSet))) ?? []
    
    let displayableJobs: [DisplayableJob] = names1.compactMap { value -> DisplayableJob? in
      guard let existingJob = jobsDict[value.0] else { return nil }
      return DisplayableJob(existingJob, productName: "", blueprintName: value.1)
    }
    
    return displayableJobs //jobs.map(\.init)
  }
  
  func makeJobsForInputSums(inputs: [Int64: Int64], assets: [Int64: Int64]) async -> [TestJob] {
    // get blueprints for input materials
    let inputMaterialIds = inputs.keys.map { $0 }
    
    let inputMaterialBlueprints = await makeBPInfos(for: inputMaterialIds)
    
    var uniqueBPs: [Int64: BPInfo] = [:]
    
    inputMaterialBlueprints.forEach { value in
      guard BlueprintIds.FuelBlocks(rawValue: value.productId) == nil else {
        return
      }
      uniqueBPs[value.productId] = value
    }
    
    let assetIds = Set(assets.keys.map { $0 })
    let inputSet = Set(inputMaterialIds)
    let missingInputIds = inputSet.subtracting(assetIds)

    let jobs: [TestJob] = missingInputIds.compactMap { key -> TestJob? in
      guard let value = inputs[key] else {
        return nil
      }
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
        blueprintId: blueprintInfo.blueprintId,
        productsPerRun: Int(blueprintInfo.productCount),
        requiredRuns: requiredRuns
      )
    }
    
    return jobs
  }
  
  func createGroupedJobs(jobs: [DisplayableJob]) async -> [DisplayableJobsGroup] {
    var productGroupsDict: [Int64: Int64] = [:]
    var groupedJobs: [Int64: [DisplayableJob]] = [:]
    
    var returnValues = [DisplayableJobsGroup]()
    
    let jobProductIds = jobs.map { $0.productId }
    let jopProductTypeModels = dbManager.getTypes(for: jobProductIds)
    // get groups for each job product
    for jobProductTypeModel in jopProductTypeModels {
      productGroupsDict[jobProductTypeModel.typeId] = jobProductTypeModel.groupID
    }
    
    // group together `DisplayableJob` that have the same group
    for job in jobs {
      let group = productGroupsDict[job.productId, default: 0]
      groupedJobs[group, default: []].append(job)
    }
    
    for jobGroup in groupedJobs {
      guard let groupName = await dbManager.getGroup(for: jobGroup.key)?.name else { continue }
      let displayableJobsGroup = DisplayableJobsGroup(
        groupName: groupName,
        groupID: jobGroup.key,
        content: jobGroup.value,
        numHave: 0
      )
      
      returnValues.append(displayableJobsGroup)
    }
    
    return returnValues
  }
}

struct DisplayableJobsGroup: Identifiable {
  var id: String { groupName }
  let groupName: String
  let groupID: Int64
  let content: [DisplayableJob]
  let numHave: Int
}
