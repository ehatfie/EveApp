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
  
  func getMissingInputs(values: [Int64: Int64], depth: Int = 0) async -> [Int64: Int64] {
    print("getMissingInputs for \(values.count)")
    guard !values.isEmpty else {
      return [:]
    }
    let start = Date()
    
    let bpInfos = await makeBPInfos(for: Array(values.keys))
    let results = bpInfos.map { ($0.blueprintId, $0.productId) }
    
    print("++ missingInput bpInfos \(bpInfos.count) \(results)")
    //print("++ makeBPInfos took \(Date().timeIntervalSince(start))")
    //let dictionary = Dictionary(uniqueKeysWithValues: bpInfos.map{ ($0.productId, $0) })
    let missingInputs = await findMissingInputs(
      bpInfos: bpInfos,
      values: values,
      depth: depth
    )
    print("got \(missingInputs.count) missing inputs \(depth) took \(Date().timeIntervalSince(start))")
    //print("getMissingInputs bulk \(values.keys)")
//    let result = await withTaskGroup(
//      of: [Int64: Int64].self,
//      returning: [Int64: Int64].self
//    ) { taskGroup in
//      for value in values {
//        taskGroup.addTask {
//          return await self.getMissingInputs(blueprintID: value.key, quantity: value.value, bpInfos: dictionary)
//        }
//      }
//      var returnValues: [Int64: Int64] = [:]
//      
//      for await value in taskGroup {
//        //print("merging \(value)")
//        returnValues.merge(value, uniquingKeysWith: +)
//      }
//      
//      return returnValues
//    }
    //print("getMissingInputs bulk took \(Date().timeIntervalSince(start))")
    return missingInputs
  }
  
  func getMissingInputs(
    blueprintID: Int64,
    quantity: Int64,
    bpInfos: [Int64: BPInfo]
  ) async -> [Int64: Int64] {
    let start = Date()
    
    //guard let bpInfo = await makeBPInfo(for: blueprintID) else {
    guard let bpInfo = bpInfos[blueprintID] else {
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
    //print("getMissingInputs took \(Date().timeIntervalSince(start))")
    return missingInputs
  }
  
  func findMissingInputs(
    bpInfos: [BPInfo],
    values: [Int64: Int64],
    depth: Int
  ) async -> [Int64: Int64] {
    let start = Date()
    var returnValues: [Int64: Int64] = [:]
    
    let inputProducts = bpInfos.flatMap { $0.inputMaterials.map { $0.id }}
    print("find missing inputs for \(inputProducts.count) input products")
    await loadCharacterAssets(for: inputProducts)
    print("related assets count \(relatedAssets.count)")
    //let assets = dbManager.getCharacterAssetsForValues(characterID: 0, typeIds: inputProducts)
    print("need values \(values)")
    print("from bpInfos \(bpInfos.map { ($0.blueprintId, $0.productId) })")
    for bpInfo in bpInfos {
      print("checking bpInfo \(bpInfo.blueprintId) \(bpInfo.productId)")
      let parentAmountNeeded = values[bpInfo.productId, default: 0]
      let productsPerRun = bpInfo.productCount
      let runsNeeded = Int64(ceil(Double(parentAmountNeeded) / Double(productsPerRun)))
      print("for \(bpInfo.blueprintId) need \(parentAmountNeeded) runs \(runsNeeded)")
      let inputMaterials = bpInfo.inputMaterials.map { ($0.id, $0.quantity)}
      print("checking inputMaterials \(inputMaterials)")
      for input in bpInfo.inputMaterials {
        let amountNeeded = input.quantity * runsNeeded
        
        guard amountNeeded > 0 else {
          print("no runs for \(bpInfo.blueprintId) \(parentAmountNeeded) \(amountNeeded)")
          continue
        }

        //returnValues[input.id, default: 0] += runsNeeded * input.quantity
        guard BlueprintIds.FuelBlocks(rawValue: input.id) == nil else {
          continue
        }
        let matchingAssetQuantity = relatedAssets[input.id, default: 0]
        let amountMissing = max(0, amountNeeded - matchingAssetQuantity)
        
        guard amountMissing > 0 else {
          print("not missing \(input.id)")
          continue
        }
//        print("Adding missing input \(input.id) matching \(matchingAssetQuantity) needed \(amountNeeded) missing \(amountMissing)")
        returnValues[input.id] = amountMissing
      }
    }
    print("got return value \(returnValues)")
    let returnValue = await getMissingInputs(values: returnValues, depth: depth + 1).merging(returnValues, uniquingKeysWith: +)
    print("findMissingInputs \(depth) took \(Date().timeIntervalSince(start))")
    return returnValue
  }
  
  func makeJobs(for values: [Int64: Int64]) -> [IndyJob] {
    return []
  }
  
  func loadCharacterAssets(for typeIds: [Int64]) async {
    guard let characterID else {
      //print("no character ID")
      return
    }
    let fetchedIds: Set<Int64> = Set(relatedAssets.map { $0.key })
    let missingIds: Set<Int64> = Set(typeIds).subtracting(fetchedIds)
    let assets = await dbManager.getCharacterAssetsForValues(
      characterID: characterID,
      typeIds: Array(missingIds)
    )
    print("++ got character assets \(assets.count)")
    for asset in assets {
      relatedAssets[asset.typeId] = asset.quantity
    }
  }
  
  func makeBPInfos(for blueprintIds: [Int64]) async -> [BPInfo] {
    var returnValues = [BPInfo]()
    let start = Date()
    for blueprintId in blueprintIds {
      guard let bpInfo = await makeBPInfo(for: blueprintId) else {
        print("no bpInfo made for \(blueprintId)")
        continue
      }
      returnValues.append(bpInfo)
    }
    print("made bpInfos \(returnValues.count)")
    //print("makeBPInfos took for \(blueprintIds.count) took \(Date().timeIntervalSince(start))")
    return returnValues
  }
  
  func makeBPInfo(for blueprintId: Int64) async -> BPInfo? {
    let blueprintModel: BlueprintModel?
    let start = Date()
    let type: String
    if let bp = await dbManager.getBlueprintModel(for: blueprintId) {
      blueprintModel = bp
      type = "Blueprint"
    } else if let bp = await dbManager.getManufacturingBlueprintAsync(making: blueprintId) {
      blueprintModel = bp
      type = "Manufacturing"
    } else if let bp = await dbManager.getReactionBlueprintAsync(for: blueprintId) {
      blueprintModel = bp
      type = "Reaction"
    } else {
      type = "None"
      blueprintModel = nil
    }
    
    guard let bpModel = blueprintModel else {
      return nil
    }
    let result = makeBPInfo(for: bpModel)
    //print("makeBPInfo type: \(type) took \(Date().timeIntervalSince(start))")
    return result
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
  
  func makeInputGroups(from values: [Int64: Int64]) async -> [IPDetailInputGroup2] {
      let start = Date()
      var returnValues: [IPDetailInputGroup2] = []
      var groupedValues: [Int64: [Int64]] = [:]
      let blueprintIds: [Int64] = values.map { $0.key }
      let inputTypeModels = dbManager.getTypes(for: blueprintIds)
      print("inputTypeModels: \(inputTypeModels.first?.name ?? "none")")
    
      var names: [Int64: String] = [:]
      let character = await dbManager.getCharacters().first!
      var relatedAssets = await dbManager.getCharacterAssetsWithTypeForValues(characterID: character.characterId, typeIds: blueprintIds)
    print("related assets fetched \(Date().timeIntervalSince(start))")
      var relatedDict: [Int64: Int64] = [:]
      
      for asset in relatedAssets {
          let existing = relatedDict[asset.asset.typeId, default: 0]
          relatedDict[asset.asset.typeId] = existing + asset.asset.quantity
      }
      let typeNames = await dbManager.getTypeNames(for: blueprintIds)
      for name in typeNames {
          names[name.typeId] = name.name
      }
    print("got \(typeNames.count) type names \(Date().timeIntervalSince(start))")
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
      let groupIds = Set(groupedValues.keys)
      let groupModels = await dbManager.getGroups(with: Array(groupIds))
    print("got groups \(groupModels.count) \(Date().timeIntervalSince(start))")
      let groupNames: [Int64: String] = groupModels.reduce(into: [:]) { $0[$1.groupId] = $1.name }
      for group in groupedValues {
        guard let groupName = groupNames[group.key] else { continue } //dbManager.getGroup(for: group.key)?.name else { continue }
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
      print("makeInputGroups took \(Date().timeIntervalSince(start)) for \(values.count)")
      return returnValues
  }
}

// MARK: - Jobs

extension IndyTool {
  func makeDisplayableJobsForInputSums(inputs: [Int64: Int64]) async -> [DisplayableJob] {
    print("makeDisplayableJobsForInputSums \(inputs)")
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
      return DisplayableJob(
        existingJob,
        productName: "",
        blueprintName: value.1
      )
    }
    
    return displayableJobs //jobs.map(\.init)
  }
  
  func makeJobsForInputSums(inputs: [Int64: Int64], assets: [Int64: Int64]) async -> [TestJob] {
    print("makeJobsForInputSums \(inputs)")
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
    let names = jobs.map { $0.blueprintName}
    print("createGroupedJobs \(names)")
    
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
