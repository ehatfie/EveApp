//
//  ReactionHelperDetailView.swift
//  EveApp
//
//  Created by Erik Hatfield on 8/23/24.
//

import ModelLibrary
import SwiftUI
import FluentKit

struct AssetRowContent: Identifiable {
  var id: Int64 { typeId }
  let name: String
  let location: String?
  let quantity: Int
  let typeId: Int64
}

struct CharacterPickerView: View {
  @Binding var characterNames: [IdentifiedString]
  @Binding var selectedCharacter: IdentifiedString?
  
  var body: some View {
    HStack {
      Picker("Character", selection: $selectedCharacter) {
        ForEach(characterNames) { characterName in
          Text(characterName.value)
            .tag(characterName)
        }
      }
      Spacer()
    }
  }
}

@Observable class ReactionHelperDetailAssetsViewModel {
  let blueprintModel: BlueprintModel
  let characterInfo: IdentifiedString
 
  var characterAssets: [AssetInfoDisplayable] = []
  var assets: [IdentifiedString] = []
  
  var assetsDict: [Int64: Int64] = [:]
  var assetNames: [Int64: IdentifiedString] = [:]
  
  init(blueprintModel: BlueprintModel, characterInfo: IdentifiedString) {
    self.blueprintModel = blueprintModel
    self.characterInfo = characterInfo
    
    Task {
      await self.getAssets()
    }
    
  }
  
  func getAssets() async {
    let dbManager = await DataManager.shared.dbManager!
    let relatedAssets = await dbManager.getCharacterAssetsForReaction(
      characterID: String(characterInfo.id),
      blueprintModel: blueprintModel
    )
    self.characterAssets = relatedAssets
    
    for asset in characterAssets {
      let existingQuantity = assetsDict[asset.asset.typeId] ?? 0
      assetsDict[asset.asset.typeId] = existingQuantity + Int64(asset.asset.quantity)
      assetNames[asset.asset.typeId] = IdentifiedString(id: asset.asset.typeId, value: asset.typeModel.name)
    }
    
    assets = assetNames.map { $0.value }
  }
  

}

// pass in some manager that caches the assets we have collected that this
// view can just ask what it wants and not have to fetch it multiple times
struct ReactionHelperDetailView: View {
  //let blueprintInfo: BlueprintInfo2
  //let blueprintDisplayInfo: [Int64: BlueprintDisplayInfo]
  
  //@Binding var nameDict: [Int64: IdentifiedString]
  @Binding var inputValues: [(IdentifiedString, IdentifiedQuantity)]
  @Binding var assetValues: [(IdentifiedString, IdentifiedQuantity)]
  @Binding var modifiedAssetValues: [(IdentifiedString, IdentifiedQuantity)]
  @Binding var productValues: [(IdentifiedString, IdentifiedQuantity)]
  //var inputMaterials: [IdentifiedQuantity]
  
  @Binding var numRuns: Int
  var pickerHandler: PickerHandler

  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        //Text("\(blueprintInfo.typeModel?.name ?? "")")
        Spacer()
        runsPicker()
      }
      
      Grid(alignment:.top) {
        //GridRow {
        HStack {
          makeBox(text: "Asset Values", items: assetValues)
          makeBox(text: "Modified Values", items: modifiedAssetValues)
        }
        //GridRow {
        HStack {
          makeBox(text: "Input Values", items: inputValues, numRuns)
          makeBox(text: "Product Values", items: productValues, numRuns)
        }
        Spacer()
      }
      
      Spacer()
    }
  }
  
  
  func makeModifiedAssets() -> some View {
    makeBox(text: "Modified Assets", items: makeModifiedAssetsItem(), numRuns)
  }
  
  func makeModifiedAssetsItem() -> [(IdentifiedString, IdentifiedQuantity)] {
    var returnValues = [(IdentifiedString, IdentifiedQuantity)]()
    
    guard !inputValues.isEmpty && !assetValues.isEmpty else { return [] }
    guard inputValues.count == assetValues.count else {
      print("InputValues \(inputValues) assetValues \(assetValues)")
      return []
    }
    print("inputvalues count \(inputValues.count)")
    for i in 0..<inputValues.count {
      let usedQuantity = inputValues[i].1.quantity * Int64(numRuns)
      
      let assetQuantity = assetValues[i].1.quantity
      let assetId = assetValues[i].1.id
      print("Start \(assetQuantity) used \(usedQuantity) end \(assetQuantity - usedQuantity)")
      let identifiedString = assetValues[i].0
      let identifiedQuantity = IdentifiedQuantity(
        id: assetId,
        quantity: assetQuantity - usedQuantity
      )
      
      let returnValue: (IdentifiedString, IdentifiedQuantity) = (identifiedString, identifiedQuantity)
      
      returnValues.append(returnValue)
    }
    print("return values \(returnValues)")
    return returnValues
  }
  
  func makeBox(
    text: String,
    items: [(IdentifiedString, IdentifiedQuantity)],
    _ runsModifier: Int = 1
  ) -> some View {
    GroupBox {
      Text(text)
      Divider()
      ScrollView {
        VStack(alignment: .leading) {
          ForEach(items, id: \.0.id) { value in
            HStack {
              Text(value.0.value)
              Spacer()
              Text("\(value.1.quantity * Int64(runsModifier))")
            }
          }
        }
      }.frame(minWidth: .zero)
    }
  }
  
  func runsPicker() -> some View {
    VStack {
      Stepper(
        label: {
          Text("Runs: \(numRuns)")
        },
        onIncrement: pickerHandler.onIncrement,
        onDecrement: {

        },
        onEditingChanged: { _ in
          
        })
    }
  }
  
  func modifiedAssetQuantity(assetTypeId: Int64) -> Int64 {
//    guard let assetsViewModel = assetsViewModel else { return 0 }
//    let existingAssets = assetsViewModel.assetsDict[assetTypeId] ?? 0
//    let inputQuantity = (inputDict[assetTypeId] ?? 0) * Int64(numRuns)
//    
//    return existingAssets - inputQuantity
    return 0
  }
  
}

#Preview {
  
//  ReactionHelperDetailView(
////    blueprintInfo: BlueprintInfo2(
////      productId: 0,
////      productCount: 0,
////      blueprintModel: BlueprintModel(),
////      typeModel: nil,
////      inputMaterials: []
////    ), blueprintDisplayInfo: [:],
////    characterInfo: nil,
////    inputMats: []
//  )
}
