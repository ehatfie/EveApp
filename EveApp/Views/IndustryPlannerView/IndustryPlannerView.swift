//
//  IndustryPlannerView.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/21/24.
//

import SwiftUI

struct IndustryConfiguration {
    let costIndices: IndustryIndices
    
    static var mock: Self {
        .init(costIndices: .empty)
    }
}

struct IPPlanPickerEntry: Identifiable {
    var id: String {
        return blueprintName
    }
    let blueprintID: Int64
    let blueprintName: String
    let runs: Int
    let materialEfficiency: Int
}

struct IndustryIndices {
    let manufacturing: Double
    let reaction: Double
    let invention: Double
    
    static var empty: Self {
        .init(manufacturing: 0.0562, reaction: 0.0338, invention: 0.03565)
    }
}

@Observable class IndustryPlannerViewModel:  PickerHandlerProtocol {
    let industryConfig: IndustryConfiguration = .mock
    
    var industryJobs: [IPPlanPickerEntry] = []
    
    var detailModel: IPDetailModel?
    
    var selectedCharacters: Set<IdentifiedString> = []
    var possibleCharacters: [IdentifiedString] = []
    
    init() {
        Task {
            let someCharacters = await DataManager.shared.dbManager!.getCharacters()
            self.possibleCharacters = someCharacters
                .compactMap { characterData -> IdentifiedString? in
                    guard
                        let characterId = Int64(characterData.characterId),
                        let publicData = characterData.publicData else {
                        return nil
                    }
                    
                    return IdentifiedString(id: characterId, value: publicData.name)
                }
            
            if let character = someCharacters.first,
               let characterId = Int64(character.characterId),
               let publicData = character.publicData {
                selectedCharacters.insert(
                    IdentifiedString(
                        id: characterId,
                        value: publicData.name
                    )
                )
            }
      
        }
        
       // possibleCharacters = (DataManager.shared.dbManager?.getAllCharacters()) ?? [].map { }
    }
    
    func addJob(
        name: String,
        runs: Int,
        materialEfficiency: Int
    ) {
        Task {
            guard let blueprintID = await DataManager.shared.dbManager?.getBlueprintId(named: name)
            else {
                return
            }
            
            let pickerEntry = IPPlanPickerEntry(
                blueprintID: blueprintID,
                blueprintName: name,
                runs: runs,
                materialEfficiency: materialEfficiency
            )
            
            industryJobs.append(pickerEntry)
        }
       
    }
    
    func removeJob(_ item: IPPlanPickerEntry) {
        industryJobs.removeAll(where: { $0.id == item.id })
    }
    
    func generate() {
        
        Task {
            guard let testObject = industryJobs.first else { return }
            
            let blueprintId = testObject.blueprintID
            
            let dbManager = await DataManager.shared.dbManager!
            guard let blueprintModel = await dbManager.getBlueprintModel(for: blueprintId) else { return }
            var assets: [TypeQuantityDisplayable] = []
            var missingAssets: [TypeQuantityDisplayable] = []
            
            var inputsDict: [Int64: Int64] = [:]
            
            let reactionInputs = blueprintModel.activities.reaction.materials
            let manufacturingInputs = blueprintModel.activities.manufacturing.materials
            
            for reactionInput in reactionInputs {
                inputsDict[reactionInput.typeId, default: 0] = reactionInput.quantity
            }
            
            for manufacturingInput in manufacturingInputs {
                inputsDict[manufacturingInput.typeId, default: 0] = manufacturingInput.quantity
            }
            
            let inputKeys: Set<Int64> = Set(inputsDict.keys)
            var assetDict: [Int64: Int64] = [:]
            
            if let selectedCharacter = selectedCharacters.first {
                let characterId = String(selectedCharacter.id)
                assets = await dbManager.getDisplayableCharacterAssetsForBlueprint(
                    characterID: characterId,
                    blueprintId: blueprintId
                )
                
                
                
                for value in assets {
                    assetDict[value.id, default: 0] = Int64(value.quantity)
                }
                
                
                let assetKeys: Set<Int64> = Set(assetDict.keys)
                
                let missingKeys: Set<Int64> = inputKeys.subtracting(assetKeys)
                let missingAssetModels = dbManager.getTypes(for: Array(missingKeys))
                
                missingAssets = missingAssetModels.compactMap { value in
                    let requiredQuantity = inputsDict[value.typeId, default: 0]
                    let characterAssetQuantity = assetDict[value.typeId, default: 0]
                    let missingQuantity = requiredQuantity - characterAssetQuantity
                    guard missingQuantity > 0 else { return nil }
                    return TypeQuantityDisplayable(quantity: requiredQuantity - characterAssetQuantity, typeModel: value)
                }
            }
            
            let inputModels = dbManager.getTypes(for: Array(inputKeys))
            let inputModelContent = inputModels.compactMap { input -> IPDetailInput? in
                let existingInputQuantity: Int64 = assetDict[input.typeId, default: 0]
                guard
                    existingInputQuantity > 0,
                    let inputQuantity = inputsDict[input.typeId] else { return nil }
                return IPDetailInput(
                    id: input.typeId,
                    name: input.name,
                    quantity: inputQuantity
                )
            }
            
            let relatedInputAssets = assets.map { asset in
                IPDetailInput(
                    id: asset.id,
                    name: asset.typeModel.name,
                    quantity: asset.quantity
                )
            }
            
            let fullyMissingAssets = missingAssets.map { asset in
                IPDetailInput(
                    id: asset.id,
                    name: asset.typeModel.name,
                    quantity: asset.quantity
                )
            }
            
            let relatedAssets = IPDetailInputGroup(
                groupName: "Existing Assets",
                content: relatedInputAssets
            )
            
            let inputs = IPDetailInputGroup(
                groupName: "Inputs",
                content: inputModelContent
            )
            
            let ipm = IndustryPlannerManager(dbManager: dbManager)
            let missingIDs = missingAssets.map { $0.id }
            var missingAssetDict: [Int64: Int64] = [:]
            
            for missingAsset in missingAssets {
                missingAssetDict[missingAsset.id] = missingAsset.quantity
            }
            
            let jobs = await ipm.makeDisplayableJobsForInputSums(inputs: missingAssetDict)
            
            self.detailModel = IPDetailModel(
                blueprintName: testObject.blueprintName,
                inputs: [inputs],
                relatedAssets: [relatedAssets],
                missingAssets: [
                    .init(groupName: "Missing Assets", content: fullyMissingAssets)
                ],
                jobs: jobs
            )
        }
    }
}

protocol PickerHandlerProtocol {
    func addJob(name: String, runs: Int, materialEfficiency: Int)
    func removeJob(_ item: IPPlanPickerEntry)
}

struct IndustryPlannerView: View {
    @State var viewModel: IndustryPlannerViewModel
    @State private var showingAlert = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                IndustryIndicesView(
                    indices: viewModel.industryConfig.costIndices
                )
                
                IPCharacterPickerView(
                    selectedCharacters: $viewModel.selectedCharacters,
                    possibleCharacters: viewModel.possibleCharacters
                ).frame(maxWidth: 250, maxHeight: 100)
                
                IPProductPickerView(
                    listData: $viewModel.industryJobs,
                    handler: viewModel.addJob,
                    hh: viewModel
                )
                
                HStack {
                    VStack(alignment: .leading) {
                        Button(action: {
                            viewModel.generate()
                        }, label: {
                            Text("Generate")
                        })
                    }
                    Spacer()
                }
                Spacer()
            }.padding(.leading, 5)
            
            if let detailModel = viewModel.detailModel {
                IPDetailView(model: detailModel)
                    .padding(.horizontal)
                    .border(.green)
            }
            Spacer()
        }.sheet(isPresented: $showingAlert, content: {
            Text("Test sheet")
        })
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Image(systemName: "plus")
                    .resizable(resizingMode: .tile)
                    .onTapGesture {
                        showingAlert = true
                    }
            }
            
        }
    }
}

struct TextFieldDropdownView: View {
    @Binding var text: String
    @State private var isPresented: Bool = false
    @Binding var searchResults: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Enter text", text: $text)
                .onChange(of: text) {
                    isPresented = !text.isEmpty
                }
            if isPresented {
                VStack(alignment: .leading) {
                    ForEach(searchResults, id: \.self) { result in
                        Text(result)
                            .onTapGesture {
                                self.text = result
                                self.isPresented = false
                            }
                    }
                }.zIndex(1)
                .padding()
            }
        }
    }
}

struct IndustryIndicesView: View {
    let indices: IndustryIndices
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            VStack(alignment: .trailing) {
                Text("Manufacturing")
                Text(String(format: "%.2f", indices.manufacturing * 100))
            }
            Text("%")
            VStack(alignment: .trailing) {
                Text("Reaction")
                Text(String(format: "%.2f", indices.reaction * 100))
            }
            Text("%")
            VStack(alignment: .trailing) {
                Text("Invention")
                Text(String(format: "%.2f", indices.invention * 100))
            }
            Text("%")
            
        }
    }
}

#Preview {
    IndustryPlannerView(viewModel: IndustryPlannerViewModel())
}
