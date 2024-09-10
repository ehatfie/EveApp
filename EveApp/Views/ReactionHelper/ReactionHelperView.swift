//
//  ReactionHelperView.swift
//  EveApp
//
//  Created by Erik Hatfield on 8/19/24.
//

import Fluent
import ModelLibrary
import SwiftUI

struct IdentifiedString: Identifiable, Hashable {
  var id: Int64
  let value: String
  let content: [IdentifiedString]?

  init(id: Int64, value: String, content: [IdentifiedString]? = nil) {
    self.id = id
    self.value = value
    self.content = content
  }
}

struct ListSection {
  let sectionName: String
  let content: [IdentifiedString]
}

private let mockFilters: [IdentifiedString] = [
  .init(
    id: 1,
    value: "First",
    content: [
      .init(id: 0, value: "Zero"),
      .init(id: 1, value: "One"),
      .init(id: 2, value: "Two"),
    ]
  ),
  .init(
    id: 2,
    value: "Second",
    content: [
      .init(id: 3, value: "Three"),
      .init(id: 4, value: "Four"),
      .init(id: 5, value: "Five"),
    ]
  ),
  .init(
    id: 3,
    value: "Third",
    content: [
      .init(id: 6, value: "Six"),
      .init(id: 7, value: "Seven"),
      .init(id: 8, value: "Eight"),
    ]
  ),
]

enum ReactionHelperReactionGroups {

}

@Observable
class ReactionInputProcessor {
  let dbManager = DataManager.shared.dbManager!
  var selectedReactions: Set<Int64> = Set<Int64>()
  var selectedReactionDisplayInfo: [Int64: BlueprintDisplayInfo] = [:]
  
  var itemNames: [Int64: IdentifiedString] = [:]
  
  var assetsDict: [Int64: Int64] = [:]
  var inputDict: [Int64: Int64] = [:]
  var productDict: [Int64: IdentifiedQuantity] = [:]
  
  var inputValues: [(IdentifiedString, IdentifiedQuantity)] = []
  var assetValues: [(IdentifiedString, IdentifiedQuantity)] = []
  var modifiedAssetValues: [(IdentifiedString, IdentifiedQuantity)] = []
  var productValues: [(IdentifiedString, IdentifiedQuantity)] = []
  
  var characterIds: [String] = []
  var numRuns: Int = 1
  
  init() {

  }
  
  func setNumRuns(_ numRuns: Int) async {
    self.numRuns = numRuns
    await updateModifiedAssets()
    await updateProductValues()
  }
  
  func updateModifiedAssets() async {
    let modifiedAssetResult: [(IdentifiedString, IdentifiedQuantity)] = inputDict
      .sorted(by: {$0.key > $1.key})
      .compactMap { key, value in
        guard value > 0 else { return nil }
        let usedQuantity = value * Int64(numRuns)
        let assetQuantity = assetsDict[key] ?? 0
        let quantity = IdentifiedQuantity(id: key, quantity: assetQuantity - usedQuantity)
        let name = itemNames[key] ?? IdentifiedString(id: key, value: "ID: \(value)")
        return (name, quantity)
      }
    
    self.modifiedAssetValues = modifiedAssetResult
  }
  
  func updateInputValues() async {
    let result: [(IdentifiedString, IdentifiedQuantity)] = inputDict
      .sorted(by: {$0.key > $1.key})
      .compactMap { key, value in
        let quantity = IdentifiedQuantity(id: key, quantity: value)
        guard value > 0 else { return nil }
        let name = itemNames[key] ?? IdentifiedString(id: key, value: "ID: \(value)")
        return (name, quantity)
      }
    
    self.inputValues = result
  }
  
  func updateAssetValues() async {
    let assetResult: [(IdentifiedString, IdentifiedQuantity)] = inputDict
      .sorted(by: {$0.key > $1.key})
      .compactMap { key, value in
        guard value > 0 else { return nil }
        let assetQuantity = assetsDict[key] ?? 0
        let quantity = IdentifiedQuantity(id: key, quantity: assetQuantity)
        let name = itemNames[key] ?? IdentifiedString(id: key, value: "ID: \(value)")
        return (name, quantity)
    }
    self.assetValues = assetResult
  }
  
  func updateProductValues() async {
    let productResult: [(IdentifiedString, IdentifiedQuantity)] = productDict.map { key, value in
      let name = itemNames[value.id] ?? IdentifiedString(id: value.id, value: "NO_NAME")
      return (name, value)
    }
    
    self.productValues = productResult
  }
  
  func addInput(blueprintId: Int64) async {
    if selectedReactions.insert(blueprintId).inserted {
      print("add input \(blueprintId) \(selectedReactions.contains(blueprintId))")
      await setSelectedReaction(blueprintId)
    }
  }
  
  func removeInput(blueprintId: Int64) async {
    print("-- remove input \(blueprintId) \(selectedReactions.contains(blueprintId))")
    if let removed = selectedReactions.remove(blueprintId) {
      // update values
      guard let existingBlueprintInfo = self.selectedReactionDisplayInfo[blueprintId] else {
        return
      }
      
      self.productDict.removeValue(forKey: blueprintId)
      
      for inputMaterial in existingBlueprintInfo.inputMaterials {
        let existingQuantity = self.inputDict[inputMaterial.id] ?? 0
        
        self.inputDict[inputMaterial.id] = max(existingQuantity - inputMaterial.quantity, 0)
      }
      
      await updateInputValues()
      await updateAssetValues()
      await updateModifiedAssets()
      await updateProductValues()
    }
  }
  
  func setSelectedReaction(_ reactionId: Int64) async {
    print("setSelectedReaction \(reactionId)")
    let dbManager = await DataManager.shared.dbManager!
    //selectedReactions.insert(reactionId)
    guard
      let blueprintModel = await dbManager.getBlueprintModel(for: reactionId)
    else { return }
    
    let blueprintInfo = makeBlueprintInfo(for: blueprintModel)
    
    self.productDict[reactionId] = IdentifiedQuantity(
      id: blueprintInfo.productId,
      quantity: blueprintInfo.productCount
    )
    
    let existingBlueprintDisplayInfo = self.selectedReactionDisplayInfo[reactionId]
    if existingBlueprintDisplayInfo == nil {
      self.selectedReactionDisplayInfo[reactionId] = BlueprintDisplayInfo(
        blueprintInfo: blueprintInfo
      )
    }
    
    var newInputs: [Int64] = [blueprintInfo.productId]
    // add inputs to inputs dictionary
    for inputMaterial in blueprintInfo.inputMaterials {
      let existingQuantity = self.inputDict[inputMaterial.typeId] ?? 0
      self.inputDict[inputMaterial.typeId] = existingQuantity + inputMaterial.quantity
      if itemNames[inputMaterial.typeId] == nil {
        newInputs.append(inputMaterial.typeId)
      }
    }
    
    addNames(for: newInputs)
    print("got new inputs \(newInputs)")
    await updateCharacterAssets()

    await updateModifiedAssets()
    await updateInputValues()
    await updateAssetValues()
    await updateModifiedAssets()
    await updateProductValues()
    print("new input vslues \(inputValues.count)")
  }
  
  private func addNames(for typeIds: [Int64]) {
    let names = dbManager.getTypeNames(for: typeIds)
    for name in names {
      itemNames[name.typeId] = IdentifiedString(id: name.typeId, value: name.name)
    }
  }
  
  
  // helper
  private func makeBlueprintInfo(
    for blueprintModel: BlueprintModel
  ) -> BlueprintInfo2 {
    print("++ make blueprint info for \(blueprintModel.blueprintTypeID)")
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

    let typeModel = DataManager.shared.dbManager!.getType(
      for: blueprintModel.blueprintTypeID)
    //let results = getTypeModels(for: inputMaterials)
    let product = manufacturing.products.first ?? reactions.products.first!
    
    return BlueprintInfo2(
      productId: product.typeId,
      productCount: product.quantity,
      blueprintModel: blueprintModel,
      typeModel: typeModel,
      inputMaterials: inputMaterials
    )
  }
  
  func setupAssets(characterNames: [IdentifiedString]) async {
    print("setupAssets \(characterNames.first?.value ?? "NO_CHARACTER")")
    self.characterIds = characterNames.map { String($0.id) }
    await updateCharacterAssets()
  }
  
  func updateCharacterAssets() async {
    print("update character assets")
    guard let characterId = characterIds.first else {
      return
    }
    
    let dbManager = await DataManager.shared.dbManager!
    let typeIds = inputDict.map { $0.key }
      .filter { value in
        return !assetsDict.contains(where: { $0.key == value })
      }
    print("checking for \(typeIds)")
    let assets = await dbManager.getCharacterAssetsForValues(characterID: characterId, typeIds: typeIds)
    print("Got \(assets.count) assets")
    for asset in assets {
      guard !assetsDict.contains(where: {$0.key == asset.typeId}) else {
        continue
    }
      
      assetsDict[asset.typeId] = asset.quantity
    }
  }
}

protocol PickerHandler {
  func onIncrement () -> Void
  func onDecrement () -> Void
}

@Observable class ReactionHelperViewModel: PickerHandler {
  var filters: [IdentifiedString] = []
  var isExpanded: Bool = false

  var selectedReaction: BlueprintInfo2?

  var selectedReactions: Set<Int64> = Set<Int64>()
  var selectedReactionDisplayInfo: [Int64: BlueprintDisplayInfo] = [:]

  var characterNames: [IdentifiedString] = []
  var selectedCharacterIdentifier: IdentifiedString?
  
  var inputMats: [IdentifiedQuantity] = []
  
  var processor: ReactionInputProcessor = ReactionInputProcessor()
  
  var numRuns: Int = 1

  init() {
    //filters = mockFilters
    
    Task {
      
      await getFilterGroups()
      await setupCharacterNames()

    }
  }
  
  

  func getFilterGroups() async {
    let groupIds = IndustryGroup.ReactionFormulas.allCases.map(\.rawValue)
    let dbManager = await DataManager.shared.dbManager!

    let groupModels = await dbManager.getGroups(with: groupIds)

    var reactionGroups: [IdentifiedString] = []

    for group in groupModels {
      let groupTypes = try! await TypeModel.query(on: dbManager.database)
        .filter(\.$groupID == group.groupId)
        .all()
        .get()

      let entry = groupTypes.map {
        IdentifiedString(id: $0.typeId, value: $0.name)
      }

      let identifiedString = IdentifiedString(
        id: group.groupId,
        value: group.name,
        content: entry
      )
      reactionGroups.append(identifiedString)
    }

    filters = reactionGroups
    //.join(CategoryModel.self, on: \CategoryModel.$categoryId == \GroupModel.$categoryID)
  }
  
  func setSelectedReaction(_ reactionId: Int64) async {
    
    if !self.selectedReactions.insert(reactionId).inserted {
      self.selectedReactions.remove(reactionId)
      await processor.removeInput(blueprintId: reactionId)
    } else {
      await processor.addInput(blueprintId: reactionId)
    }
  }

  func setupCharacterNames() async {
    let dbManager = await DataManager.shared.dbManager!
    let characters = await dbManager.getCharacters()
    let characterNames: [IdentifiedString] = characters.compactMap({
      character in
      guard let publicData = character.publicData,
        let characterId = Int64(character.characterId)
      else { return nil }

      return IdentifiedString(
        id: characterId,
        value: publicData.name
      )
    })

    self.selectedCharacterIdentifier = characterNames.first
    self.characterNames = characterNames
    await self.processor.setupAssets(characterNames: characterNames)
  }
  
  func onIncrement() {
    numRuns += 1
    Task {
      await processor.setNumRuns(numRuns)
    }
    
  }
  
  func onDecrement() {
    if numRuns > 0 {
      numRuns -= 1
      Task {
        await processor.setNumRuns(numRuns)
      }
    }
  }
}

struct ReactionHelperView: View {
  @State var viewModel: ReactionHelperViewModel = ReactionHelperViewModel()

  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      HStack {
        VStack(alignment: .leading) {
          CharacterPickerView(
            characterNames: $viewModel.characterNames,
            selectedCharacter: $viewModel.selectedCharacterIdentifier
          )
          reactionList()
        }.frame(maxWidth: 300)
        Divider()
        ReactionHelperDetailView(
          inputValues: $viewModel.processor.inputValues,
          assetValues: $viewModel.processor.assetValues,
          modifiedAssetValues: $viewModel.processor.modifiedAssetValues,
          productValues: $viewModel.processor.productValues,
          numRuns: $viewModel.numRuns,
          pickerHandler: self.viewModel
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)

      }
    }
    .padding()
  }

  func reactionList() -> some View {
    List(viewModel.filters, children: \.content) { value in
      Text(value.value)
        .background(
          viewModel.selectedReactions.contains(value.id)
                    ? Color.blue : Color.clear
        )
        .lineLimit(3)
        .onTapGesture {
          Task {
            await viewModel.setSelectedReaction(value.id)
          }
        }
    }.listStyle(.sidebar)
  }

  func reactionStack() -> some View {
    VStack {
      DisclosureGroup(
        content: {
          VStack(alignment: .leading) {
            Text("One")
            Text("Two")
            Text("Three")
          }
        },
        label: {
          Text("DisclosureGroup")
        })
      Spacer()
    }
  }

  func detailView() -> some View {
    VStack {
      HStack {
        Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }  //.frame(width: 400)
  }
}

#Preview {
  ReactionHelperView()
  //        .frame(maxWidth: 250, maxHeight: 250)
}
