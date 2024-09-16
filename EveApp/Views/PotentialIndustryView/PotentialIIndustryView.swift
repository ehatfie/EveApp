//
//  PotentialIIndustryView.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/27/24.
//

import SwiftUI
import FluentKit
import ModelLibrary

struct AssetInfoDisplayable {
  let asset: CharacterAssetsDataModel
  let typeModel: TypeModel
}

struct TypeQuantityDisplayable {
  var id: Int64 {
    typeModel.typeId
  }
  let quantity: Int
  let typeModel: TypeModel
}

@Observable class PotentialIndustryViewModel {
  var selectedCharacters: [CharacterDataModel] = []
  var assetsDictionary: [String] = []
  
  var assets: [AssetInfoDisplayable] = []
  var assetsDisplayable: [TypeQuantityDisplayable] = []
  var blueprintNames: [TypeNamesResult] = []
  
  var filters = Set<PotentialIndustryFilter>()
  var selectedGroupFilters = Set<Int64>(
    [IndustryGroup.Materials.constructionComponents.rawValue]
  )
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
    let characterModels = await DataManager.shared.dbManager!.getCharactersWithInfo()
    print("got \(characterModels.count) character models")
    self.selectedCharacters = characterModels
  }
  
  func getGroupFilters() async {
    let reactionGroups = await DataManager.shared.dbManager!
      .getGroups(with: IndustryGroup.Reactions.allCases.map { $0.rawValue })
      .sorted(by: {$0.groupId < $1.groupId})
      .map { PIGroupFilterDisplayable(groupModel: $0)}
    
    let materialGroups = await DataManager.shared.dbManager!
      .getGroups(with: IndustryGroup.Materials.allCases.map { $0.rawValue })
      .sorted(by: {$0.groupId < $1.groupId})
      .map { PIGroupFilterDisplayable(groupModel: $0)}
    
    self.groupFilters = reactionGroups + materialGroups
    self.filterGroups = [
      PIFilterGroup(title: "Reactions", filters: reactionGroups),
      PIFilterGroup(title: "Materials", filters: materialGroups)
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
        groupIDs = groups.map({$0.rawValue})
      }
      
      let assets = try await CharacterAssetsDataModel.query(on: dbManager.database)
        .join(TypeModel.self, on: \CharacterAssetsDataModel.$typeId == \TypeModel.$typeId)
        .filter(TypeModel.self, \.$groupID ~~ groupIDs)
        .all()
      
      let assetInfos: [AssetInfoDisplayable] = assets.compactMap { asset -> AssetInfoDisplayable? in
        guard let typeModel = try? asset.joined(TypeModel.self) else {
          return nil
        }
        
        return AssetInfoDisplayable(asset: asset, typeModel: typeModel)
      }
      
      let typeModels = try await TypeModel.query(on: dbManager.database)
        .filter(\.$groupID ~~ groupIDs)
        .all()
      
      let assetDictionary: [Int64: TypeQuantityDisplayable] = assetInfos.reduce(into: [:]) { result, assetInfo in
        let key = assetInfo.asset.typeId
        
        if let existingValue = result[key] {
          let newQuantity = existingValue.quantity + assetInfo.asset.quantity
          result[key] = TypeQuantityDisplayable(
            quantity: newQuantity,
            typeModel: existingValue.typeModel
          )
        }
        
        result[key] = TypeQuantityDisplayable(
          quantity: assetInfo.asset.quantity,
          typeModel: assetInfo.typeModel
        )
      }
      assetsDisplayable = Array(assetDictionary.values)
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
  
  func getMakesStuff() async {
    var itemsDictionary: [Int64: Int] = [:]
    for asset in assets {
      let currentValue = itemsDictionary[asset.asset.typeId] ?? 0
      itemsDictionary[asset.asset.typeId] = currentValue + asset.asset.quantity
    }
    
    let keys = itemsDictionary.keys
    print("checking against \(keys)")
    
    let reactionModels = await DataManager.shared.dbManager!.getReactionBlueprintsWIthInputs(of: Array(keys))
    let manufacturingModels = await DataManager.shared.dbManager!
      .getManufacturingBlueprintsWithInputs(of: Array(keys))
    
    print("got \(reactionModels.count) reaction blueprintModels")
    print("got \(manufacturingModels.count) manufacturing blueprintModels")
    
    let blueprintIds = (reactionModels + manufacturingModels).map { $0.blueprintTypeID }
    let blueprintTypeNames = await DataManager.shared.dbManager!
      .getTypeNames(for: blueprintIds)
    
    //print("blueprint type names \(blueprintTypeNames)")
    
    blueprintNames = blueprintTypeNames
  }
  
  func setBlueprintDetail(for typeId: Int64) async {
    print("set blueprint Detail \(typeId)")
    await self.industryPlannerManager.createIndustryJobPlan(
      for: typeId
    )
    guard let blueprintModel = await dbManager.getBlueprintModel(for: typeId) else {
      blueprintDetails = nil
      return
    }
    //print("got blueprintModel \(blueprintModel.blueprintTypeID)")
    blueprintDetails = blueprintModel
    
//    await self.industryPlannerManager.createIndustryJobPlan(
//      for: blueprintModel.blueprintTypeID
//    )
    
  }
}

struct PotentialIIndustryView: View {
  @Bindable var viewModel: PotentialIndustryViewModel = PotentialIndustryViewModel()
  
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
        VStack(alignment: .leading) {
          Text("Assets")
          
          ScrollView {
            VStack(alignment: .leading, spacing: 5) {
              ForEach(viewModel.assetsDisplayable, id: \.id) { asset in
                HStack() {
                  Text("\(asset.typeModel.name)")
                  Spacer()
                  
                  Text("\(asset.quantity)")
                }
              }
            }.frame(maxWidth: 250)
          }
          
          if !viewModel.blueprintNames.isEmpty {
            Text("Makes")
            ScrollView {
              VStack(alignment: .leading, spacing: 5) {
                ForEach(viewModel.blueprintNames, id: \.typeId) { typeNameResult in
                  HStack {
                    Text("\(typeNameResult.name)")
                    Spacer()
                  }.onTapGesture {
                    Task {
                      await viewModel.setBlueprintDetail(for: typeNameResult.typeId)
                    }
                  }
                }
              }.frame(maxWidth: 250)
              
            }
          }
        }
        
        VStack(alignment: .leading) {
          if let blueprintDetails = viewModel.blueprintDetails {
            BlueprintDetailView(
              blueprint: blueprintDetails,
              industryPlanner: IndustryPlannerManager(
                dbManager: DataManager.shared.dbManager!
              )
            )
            //BlueprintDetailView1()
          } else {
            EmptyView().frame(maxWidth: .infinity, maxHeight: .infinity)
          }
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
    VStack {
      //ForEach(viewModel.)
    }
  }
  
  func buttons() -> some View {
    VStack(alignment: .leading) {
      HStack {
        Button(action: {
          Task {
            await viewModel.getAssets()
          }
          
        }, label: {
          Text("Get Assets")
        })
        
        Button(action: {
          Task {
            await viewModel.getMakesStuff()
          }
          
        }, label: {
          Text("Get Makes")
        })
      }
    }
  }
}

#Preview {
  PotentialIIndustryView()
}
