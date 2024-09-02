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
  
  
  
  func addInput(blueprintId: Int64) async {
    if selectedReactions.insert(blueprintId).inserted {
      await setSelectedReaction(blueprintId)
    }
  }
  
  func removeInput(blueprintId: Int64) async {
    if let removed = selectedReactions.remove(blueprintId) {
      // update values
    }
  }
  
  func setSelectedReaction(_ reactionId: Int64) async {
    print("setSelectedReaction \(reactionId)")
    let dbManager = await DataManager.shared.dbManager!

    guard
      let blueprintModel = await dbManager.getBlueprintModel(for: reactionId)
    else { return }
    
    let blueprintInfo = makeBlueprintInfo(for: blueprintModel)
    //self.selectedReaction = blueprintInfo
    
    let existingBlueprintDisplayInfo = self.selectedReactionDisplayInfo[reactionId]
    if existingBlueprintDisplayInfo == nil {
      self.selectedReactionDisplayInfo[reactionId] = BlueprintDisplayInfo(
        blueprintInfo: blueprintInfo
      )
    }
    var newInputs: [Int64] = []
    // add inputs to inputs dictionary
    for inputMaterial in blueprintInfo.inputMaterials {
      let existingQuantity = self.inputDict[inputMaterial.typeId] ?? 0
      self.inputDict[inputMaterial.typeId] = existingQuantity + inputMaterial.quantity
      if itemNames[inputMaterial.typeId] == nil {
        newInputs.append(inputMaterial.typeId)
      }
    }
    
    addNames(for: newInputs)
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
}



@Observable class ReactionHelperViewModel {
  var filters: [IdentifiedString] = []
  var isExpanded: Bool = false

  var selectedReaction: BlueprintInfo2?

  var selectedReactions: Set<Int64> = Set<Int64>()
  var selectedReactionDisplayInfo: [Int64: BlueprintDisplayInfo] = [:]

  var characterNames: [IdentifiedString] = []
  var selectedCharacterIdentifier: IdentifiedString?
  
  var inputMats: [IdentifiedQuantity] = []
  
  let processor: ReactionInputProcessor = ReactionInputProcessor()

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
    await processor.setSelectedReaction(reactionId)
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
        if let blueprintInfo = self.viewModel.selectedReaction {
          ReactionHelperDetailView(
            blueprintInfo: blueprintInfo,
            blueprintDisplayInfo: viewModel.selectedReactionDisplayInfo,
            characterInfo: viewModel.selectedCharacterIdentifier,
            inputMats: viewModel.inputMats
          )
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          Spacer()
            .frame(maxWidth: .infinity)
        }

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
