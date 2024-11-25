//
//  PotentialIIndustryView.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/27/24.
//

import FluentKit
import ModelLibrary
import SwiftUI

@Observable class PotentialIndustryViewModel {
  var selectedCharacters: [CharacterDataModel] = []
  var assetsDictionary: [Int64: TypeQuantityDisplayable] = [:]

  var assets: [AssetInfoDisplayable] = []
  var assetsDisplayable: [TypeQuantityDisplayable] = []
  
  var blueprintModels: [BlueprintModel] = []
  var blueprintNames: [TypeNamesResult] = []

  var filters = Set<PotentialIndustryFilter>()
  var selectedGroupFilters = Set<Int64>([
    IndustryGroup.Materials.moonMaterials.rawValue
  ])
  
  var selectedAssets: Set<Int64> = []
  var selectedBlueprints: Set<Int64> = []

  var groupFilters = [PIGroupFilterDisplayable]()
  var filterGroups: [PIFilterGroup] = []

  var blueprintDetails: BlueprintModel?

  let industryPlannerManager: IndustryPlannerManager
  let dbManager: DBManager

  init() {
    self.dbManager = DataManager.shared.dbManager!
    self.industryPlannerManager = IndustryPlannerManager(dbManager: dbManager)
    Task {
      await setupSelectedCharacters()
      await getGroupFilters()
      await getAssets()
      await getMakesStuff()
    }
  }

  func setupSelectedCharacters() async {
    // overkill on what we are querying
    let characterModels = await DataManager.shared.dbManager!
      .getCharactersWithInfo()
    print("got \(characterModels.count) character models")
    self.selectedCharacters = characterModels
  }

  func getGroupFilters() async {
    let reactionGroups = await DataManager.shared.dbManager!
      .getGroups(with: IndustryGroup.Reactions.allCases.map { $0.rawValue })
      .sorted(by: { $0.groupId < $1.groupId })
      .map { PIGroupFilterDisplayable(groupModel: $0) }

    let materialGroups = await DataManager.shared.dbManager!
      .getGroups(with: IndustryGroup.Materials.allCases.map { $0.rawValue })
      .sorted(by: { $0.groupId < $1.groupId })
      .map { PIGroupFilterDisplayable(groupModel: $0) }

    self.groupFilters = reactionGroups + materialGroups
    self.filterGroups = [
      PIFilterGroup(title: "Reactions", filters: reactionGroups),
      PIFilterGroup(title: "Materials", filters: materialGroups),
    ]
  }

  func characterList() -> [CharacterDataModel] {

    return []
  }

  func getAssets() async {
    self.blueprintNames = []
    self.blueprintDetails = nil
    // Given an array of items we want to figure out what things it goes into
    let dbManager = await DataManager.shared.dbManager!
    do {
      var groupIDs: [Int64] = Array(selectedGroupFilters)

      if groupIDs.isEmpty {
        let groups: [any GroupEnum] = [
          IndustryGroup.Reactions.simpleReactions,
          IndustryGroup.Reactions.complexReactions,
          IndustryGroup.Materials.moonMaterials,
          IndustryGroup.Materials.intermediateMaterials,
          IndustryGroup.Materials.constructionComponents,
          IndustryGroup.Materials.composites,
        ]
        groupIDs = groups.map({ $0.rawValue })
      }

      let assets = try await CharacterAssetsDataModel.query(
        on: dbManager.database
      )
      .join(
        TypeModel.self,
        on: \CharacterAssetsDataModel.$typeId == \TypeModel.$typeId
      )
      .filter(TypeModel.self, \.$groupID ~~ groupIDs)
      .all()

      let assetInfos: [AssetInfoDisplayable] = assets.compactMap {
        asset -> AssetInfoDisplayable? in
        guard let typeModel = try? asset.joined(TypeModel.self) else {
          return nil
        }

        return AssetInfoDisplayable(asset: asset, typeModel: typeModel)
      }

      let typeModels = try await TypeModel.query(on: dbManager.database)
        .filter(\.$groupID ~~ groupIDs)
        .all()

      let assetDictionary: [Int64: TypeQuantityDisplayable] = assetInfos.reduce(
        into: [:]) { result, assetInfo in
          let key = assetInfo.asset.typeId

          if let existingValue = result[key] {
            let newQuantity =
              Int64(existingValue.quantity) + Int64(assetInfo.asset.quantity)
            result[key] = TypeQuantityDisplayable(
              quantity: newQuantity,
              typeModel: existingValue.typeModel
            )
          }

          result[key] = TypeQuantityDisplayable(
            quantity: Int64(assetInfo.asset.quantity),
            typeModel: assetInfo.typeModel
          )
        }
      assetsDictionary = assetDictionary
      assetsDisplayable = Array(assetDictionary.values)
        .sorted(by: {
          $0.quantity > $1.quantity
        })
      print("got \(typeModels.count) type models")
      print("matching assets \(assets.count)")
      print("typeModel names \(typeModels.map{ $0.name })")

      print("character assets \(selectedCharacters[0].assetsData.count)")

      let assets1 = selectedCharacters.map { $0.assetsData }
      print("got \(assets1.count) asset lists of \(assets1.first?.count ?? -1)")
      self.assets = assetInfos
    } catch let error {
      print("doThing error \(error)")
    }

  }

  // Gets the blueprints that the current assets could make
  func getMakesStuff() async {
    var itemsDictionary: [Int64: Int] = [:]

    for asset in assets {
      guard selectedAssets.contains(asset.asset.typeId) else { continue }
      itemsDictionary[asset.asset.typeId, default: 0] += Int(asset.asset.quantity)
    }

    let keys = itemsDictionary.keys
    print("checking against \(keys)")

    let reactionModels: [BlueprintModel] = await DataManager.shared.dbManager!
      .getReactionBlueprintsWIthInputs(of: Array(keys))
    let manufacturingModels: [BlueprintModel] = await DataManager.shared.dbManager!
      .getManufacturingBlueprintsWithInputs(of: Array(keys))

    print("got \(reactionModels.count) reaction blueprintModels")
    print("got \(manufacturingModels.count) manufacturing blueprintModels")

    let blueprintIds = (reactionModels + manufacturingModels).map {
      $0.blueprintTypeID
    }
    let blueprintTypeNames = await DataManager.shared.dbManager!
      .getTypeNames(for: blueprintIds)

    self.blueprintModels = reactionModels + manufacturingModels
    blueprintNames = blueprintTypeNames
  }

  // determines the jobs you need to run to use all the provided assets
  func optimizeAssets() async {
    var assetsDict: [Int64: Int64] = [:]
    //var inputsDict: [Int64: Int64] = [:]
    
    for assetId in selectedAssets {
      // unwrap optional
      guard let existing: TypeQuantityDisplayable = assetsDictionary[assetId] else {
        continue
      }
      
      assetsDict[assetId] = existing.quantity
    }
    
    var missingInputsDict: [Int64: Int64] = [:]
    
    for blueprintModel in blueprintModels {
      
      let reactionMaterials = blueprintModel.activities.reaction.materials
      let manufacturingMaterials = blueprintModel.activities.manufacturing.materials
      let inputMaterials: [QuantityTypeModel] = reactionMaterials + manufacturingMaterials
      
      var maxRuns: Int64 = 0
      
      // get character assets for all input materials
      for inputMaterial in inputMaterials {
        guard let existing: TypeQuantityDisplayable = assetsDictionary[inputMaterial.typeId] else {
          missingInputsDict[inputMaterial.typeId] = inputMaterial.quantity
          continue
        }
        //print("existing for \(existing.typeModel.name) \(existing.quantity)")
        let runs = existing.quantity % inputMaterial.quantity
        maxRuns = max(maxRuns, runs)
      }
      
      print("Max runs for \(blueprintModel.blueprintTypeID) \(maxRuns)")
      
    }
    
    //let relatedBlueprints = await getBlueprintModels(for: keys)
  }

  func getBlueprintModels(for keys: [Int64]) async -> [BlueprintModel] {
    let dbManager = await DataManager.shared.dbManager!
    let reactionModels = await dbManager.getReactionBlueprintsWIthInputs(
      of: Array(keys))
    let manufacturingModels =
      await dbManager.getManufacturingBlueprintsWithInputs(of: Array(keys))

    return reactionModels + manufacturingModels
  }

  func setBlueprintDetail(for typeId: Int64) async {
    print("set blueprint Detail \(typeId)")
    await self.industryPlannerManager.createIndustryJobPlan(
      for: typeId
    )
    guard let blueprintModel = await dbManager.getBlueprintModel(for: typeId)
    else {
      blueprintDetails = nil
      return
    }

    blueprintDetails = blueprintModel

  }

  func getReactionFilterConfig() -> ReactionFilterConfig {
    let reactionBlueprints = dbManager.getReactionBlueprints1(
      groups: IndustryGroup.ReactionFormulas.allCases
    )  //(for: assetKeys)

    var reactionGroups: [Int64: [TypeModel]] = [:]

    for blueprintEntry in reactionBlueprints {
      //let blueprint = blueprintEntry.0
      let typeModel = blueprintEntry  //.1

      let existingValues = reactionGroups[typeModel.groupID, default: []]
      reactionGroups[typeModel.groupID] = existingValues + [typeModel]
    }

    let content = reactionGroups.compactMap { key, value -> IdentifiedString? in
      let values = value.map { IdentifiedString(id: $0.typeId, value: $0.name) }
      guard let group = dbManager.getGroup(for: key) else { return nil }
      print(
        "reaction group key \(key) count \(values.count) name \(group.name)")
      return IdentifiedString(
        id: key,
        value: group.name,
        content: values
      )
    }

    return ReactionFilterConfig(
      title: "Reaction Filter",
      content: content
    )
  }
}

// Selection
extension PotentialIndustryViewModel {
  func didSelectAsset(id: Int64) {
    if !self.selectedAssets.insert(id).inserted {
      self.selectedAssets.remove(id)
    }
    
    Task {
      await getMakesStuff()
    }
  }
  
  func didSelectBlueprint(id: Int64) {
    if !selectedBlueprints.insert(id).inserted {
      selectedBlueprints.remove(id)
    }
  }
}

struct PotentialIIndustryView: View {
  @Bindable var viewModel: PotentialIndustryViewModel =
    PotentialIndustryViewModel()
  @State var showReactionFilterList: Bool = false
  @State var expandedSet: Set<Int64> = []
  
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("Hello World")
        Spacer()
      }.border(.green)

      PotentialIndustryFiltersView(
        selectedItems: Set<PotentialIndustryFilter>(),
        selectedGroupFilters: $viewModel.selectedGroupFilters,
        groupFilters: viewModel.filterGroups
      )

      activeCharacters()
      HStack {
        HStack(alignment: .top, spacing: 10) {
          VStack(alignment: .leading) {
            Text("Assets")
              .font(.headline)
            assetsList()
          }
          
          Divider()
          
          VStack(alignment: .leading) {
            Text("Makes")
              .font(.headline)
            if !viewModel.blueprintNames.isEmpty {
              blueprintsList()
            }
          }
        }


        VStack(alignment: .leading) {

        }

      }
      Spacer()

      buttons()
    }.frame(maxWidth: .infinity)
      .padding(.horizontal, 15)
      .padding(.bottom, 10)
      .border(.blue)
  }

  func activeCharacters() -> some View {
    // list of characters to include
    VStack {
      Text("Selected Characters")
    }
  }

  func assetsList() -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 5) {
        ForEach(viewModel.assetsDisplayable, id: \.id) { asset in
          HStack {
            Text("\(asset.typeModel.name)")
            Spacer()
            Text("\(asset.quantity)")
          }
          .border(viewModel.selectedAssets.contains(asset.id) ? .blue : .clear)
          .onTapGesture {
            viewModel.didSelectAsset(id: asset.id)
          }
        }
      }.frame(maxWidth: 250)
    }

  }
  
  func blueprintsList() -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 5) {
        ForEach(viewModel.blueprintNames, id: \.typeId) { typeNameResult in
          HStack {
            Text("\(typeNameResult.name)")
            Spacer()
          }
          .border(viewModel.selectedBlueprints.contains(typeNameResult.typeId) ? .blue : .clear)
          .onTapGesture {
            viewModel.didSelectBlueprint(id: typeNameResult.typeId)
          }
        }
      }.frame(maxWidth: 250)

    }
  }

  func buttons() -> some View {
    VStack(alignment: .leading) {
      HStack {
        Button(
          action: {
            Task {
              await viewModel.getAssets()
            }

          },
          label: {
            Text("Get Assets")
          })

        Button(
          action: {
            Task {
              await viewModel.getMakesStuff()
            }

          },
          label: {
            Text("Get Makes")
          })

        Button(
          action: {
            Task {
              await viewModel.optimizeAssets()
            }

          },
          label: {
            Text("Process")
          })

        Button(
          action: {
            showReactionFilterList = true
          },
          label: {
            Text("Reaction List")
          }
        )
        .sheet(
          isPresented: $showReactionFilterList,
          content: {
            ReactionFilterView(
              items: viewModel.getReactionFilterConfig(),
              expandedSet: $expandedSet
            )
          })
      }
    }
  }
}

#Preview {
  PotentialIIndustryView()
}

/*
 Step 1 select your assets
 Step 2 select the things you want to make for each asset

 optimize for race only?
 */


struct SelectionList: View {
  @Binding var selection: Set<Int64>
  var body: some View {
    VStack {
      
    }
  }
}


