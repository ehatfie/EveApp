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
  let blueprintInfo: BlueprintInfo2
  let blueprintDisplayInfo: [Int64: BlueprintDisplayInfo]
  let characterInfo: IdentifiedString?
  
  let assetsViewModel: ReactionHelperDetailAssetsViewModel?
  var nameDict: [Int64: String] = [:]
  var inputDict: [Int64: Int64] = [:]
  
  var inputMaterials: [IdentifiedQuantity]
  
  @State var numRuns: Int = 1

  init(
    blueprintInfo: BlueprintInfo2,
    blueprintDisplayInfo: [Int64: BlueprintDisplayInfo],
    characterInfo: IdentifiedString?,
    inputMats: [IdentifiedQuantity]
  ) {
    self.blueprintInfo = blueprintInfo
    self.characterInfo = characterInfo
    self.blueprintDisplayInfo = blueprintDisplayInfo
    if let characterInfo = characterInfo {
      self.assetsViewModel = ReactionHelperDetailAssetsViewModel(
        blueprintModel: blueprintInfo.blueprintModel,
        characterInfo: characterInfo
      )
      
    } else {
      assetsViewModel = nil
    }
    let allInputs = Array(blueprintDisplayInfo.values)
      .map {
        $0.inputMaterials
      }.flatMap{ $0 }
    
    let allInputIds = allInputs.map{ $0.id }
    print("all input ids count \(allInputIds.count)")
    let inputTypeIds = blueprintInfo.inputMaterials.map { $0.typeId }
    + [blueprintInfo.productId]
    + allInputIds
    
    let typeModels = try! TypeModel.query(on: DataManager.shared.dbManager!.database)
      .filter(\.$typeId ~~ inputTypeIds)
      .all()
      .wait()
    
    
    for typeModel in typeModels {
      nameDict[typeModel.typeId] = typeModel.name
    }
    
    let inputMaterials = allInputs //blueprintInfo.inputMaterials
  
    for inputMaterial in inputMaterials {
      inputDict[inputMaterial.id] = inputMaterial.quantity
    }
    
    self.inputMaterials = inputMats
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        ForEach(Array(self.blueprintDisplayInfo.values), id: \.blueprintId) { entry in
          Text(entry.blueprintName)
        }
        //Text("\(blueprintInfo.typeModel?.name ?? "")")
        Spacer()
        runsPicker()
      }
      
      Grid(alignment:.top) {
        GridRow {
          //HStack(alignment: .top) {
          VStack(alignment: .leading) {
            if let assetsViewModel = assetsViewModel {
              assetsView(assetsViewModel: assetsViewModel)
            }
            
            if let assetsViewModel = assetsViewModel {
              //VStack {
              HStack(alignment: .top) {
                GroupBox(
                  content: {
                    VStack(alignment: .leading) {
                      ForEach(inputMaterials, id: \.id) { inputMaterial in
                        HStack {
                          Text(nameDict[inputMaterial.id] ?? "")
                          Spacer()
                          Text("\(inputMaterial.quantity * Int64(numRuns))")
                        }
                      }
                    }
                  },
                  label: {
                    Label("Inputs", systemImage: "creditcard.fill")
                  }
                )
                
                GroupBox(
                  content: {
                    HStack {
                      Text(nameDict[blueprintInfo.productId] ?? "")
                      Spacer()
                      Text("\(blueprintInfo.productCount * Int64(numRuns))")
                    }
                    
                  },
                  label: {
                    Label("Output", systemImage: "creditcard.fill")
                  }
                )

              }
            }
          }
        }
      }
      Spacer()
    }
  }
  
  @ViewBuilder
  func assetsView(assetsViewModel: ReactionHelperDetailAssetsViewModel) -> some View {
      //VStack {
      HStack(alignment: .center) {
        GroupBox(
          content: {
            VStack(alignment: .leading) {
              ForEach(
                assetsViewModel.assets,
                id: \.id
              ) { assetInfoDisplayable in
                HStack {
                  Text(assetInfoDisplayable.value)
                  Spacer()
                  Text("\(assetsViewModel.assetsDict[assetInfoDisplayable.id] ?? 0)")
                }
                
              }
            }
          },
          label: {
            Label(
              "Relevant Assets for \(characterInfo?.value ?? "nil")",
              systemImage: "creditcard.fill")
          }
        )
        
        GroupBox(
          content: {
            VStack(alignment: .leading) {
              ForEach(
                assetsViewModel.assets,
                id: \.id
              ) { assetInfoDisplayable in
                HStack {
                  Text(assetInfoDisplayable.value)
                  Spacer()
                  Text("\(modifiedAssetQuantity(assetTypeId: assetInfoDisplayable.id))")
                }
                
              }
            }
          },
          label: {
            Label(
              "Outcome Assets for \(characterInfo?.value ?? "nil")",
              systemImage: "creditcard.fill")
          }
        )
      }
  }
  
  func runsPicker() -> some View {
    VStack {
      Stepper(
        label: {
          Text("Runs: \(numRuns)")
        },
        onIncrement: {
          numRuns += 1
        },
        onDecrement: {
          if numRuns > 0 {
            numRuns -= 1
          }
        },
        onEditingChanged: { _ in
          
        })
    }
  }
  
  func modifiedAssetQuantity(assetTypeId: Int64) -> Int64 {
    guard let assetsViewModel = assetsViewModel else { return 0 }
    let existingAssets = assetsViewModel.assetsDict[assetTypeId] ?? 0
    let inputQuantity = (inputDict[assetTypeId] ?? 0) * Int64(numRuns)
    
    return existingAssets - inputQuantity
  }
  
}

#Preview {
  
  ReactionHelperDetailView(
    blueprintInfo: BlueprintInfo2(
      productId: 0,
      productCount: 0,
      blueprintModel: BlueprintModel(),
      typeModel: nil,
      inputMaterials: []
    ), blueprintDisplayInfo: [:],
    characterInfo: nil,
    inputMats: []
  )
}
