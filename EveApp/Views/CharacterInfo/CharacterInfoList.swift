//
//  CharacterInfoList.swift
//  EveApp
//
//  Created by Erik Hatfield on 12/5/24.
//

import SwiftUI
import ModelLibrary

@Observable class CharacterInfoListViewModel {
    var dbManager: DBManager
    var characterModels: [CharacterDataModel] = []
    var characterInfoDisplayables: [CharacterInfoDisplayable]  = []
    
    var selectedCharacters: Set<IdentifiedString> = []
    var possibleCharacters: [IdentifiedString] = []
    
    var corpInfos: [IdentifiedString] = []
    
    init(dbManager: DBManager) {
        self.dbManager = dbManager

        Task {
            await loadCharacters()
            await getCorps()
        }
    }
    
    func loadCharacters() async {
        print("loadCharacters")
        let characterInfo = await dbManager.getCharactersWithInfo()
        print("loadedCharacters")
        characterModels = characterInfo
        self.characterInfoDisplayables = await dbManager.getCharacterInfoDisplayable()
        self.possibleCharacters = characterInfo
            .compactMap { characterData -> IdentifiedString? in
                guard
                    let characterId = Int64(characterData.characterId),
                    let publicData = characterData.publicData else {
                    return nil
                }
                
                return IdentifiedString(id: characterId, value: publicData.name)
            }
    }
    
    func updateCharacterWallet(characterId: String) {
        Task {
            await DataManager.shared.updateCharacterWallet(characterId: characterId)
        }
    }
    
    func updateCharacterAssets(characterId: String) {
        Task {
            await DataManager.shared.fetchAssetsAsync(characterId: characterId)
        }
    }
    
    func updateCharacterIndustry(characterId: String) {
        Task {
            await DataManager.shared.fetchIndustryJobsForCharacters(characterId: characterId)
        }
    }
    
    func getCorps() async {
        let corps = await dbManager.getCorporationModels()
        self.corpInfos = corps.map {
            IdentifiedString(id: Int64($0.corporationId), value: $0.name)
        }
    }
}

struct CharacterInfoList: View {
    @State var viewModel: CharacterInfoListViewModel
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Button(action: {
                    Task {
                        try? await DataManager.shared.fetchAllCharacterInfoAsync()
                    }
                }, label: {
                    Text("Fetch all character info")
                })
                
                Button(action: {
                    Task {
                        try? await DataManager.shared.fetchAllCharacterInfoAsync()
                    }
                }, label: {
                    Text("Fetch all character corps")
                })
                
                Button(action: {
                    Task {
                        try? await DataManager.shared.attachCharacterCorpAsync()
                    }
                }, label: {
                    Text("Attach character corps")
                })
            }
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 400, maximum: 800)),
                GridItem(.adaptive(minimum: 400, maximum: 800)),
                GridItem(.adaptive(minimum: 400, maximum: 800))
            ]) {
                ForEach(viewModel.characterInfoDisplayables) { characterInfo in
                    characterInfoCard(characterInfo)
                        .frame(alignment: .center)
                }
            }.border(.blue)
            
            VStack(alignment: .leading) {
                Text("Corps")
                    .font(.headline)
                ForEach(viewModel.corpInfos) { info in
                    Text(info.value)
                }
            }

        }
    }
    
    @ViewBuilder
    func characterInfoCard(_ characterInfo: CharacterInfoDisplayable) -> some View {
        GroupBox {
            VStack(spacing: 15) {
                    Text(characterInfo.name)
                    
                VStack(alignment: .trailing, spacing: 5) {
                        Text(characterInfo.corporationInfo.value)
                        if let walletModel = characterInfo.walletModel {
                            Text(df2so(walletModel.$balance.wrappedValue ?? 0.00) + " ISK")
                        }
                    }
                    
                    buttons(characterInfo: characterInfo)
                    //GlassEffectContainer(spacing: 40) {

                    //}
                }
            .padding()
        }

    }
    
    @ViewBuilder
    func characterPublicData(_ publicData: CharacterPublicDataModel) -> some View {
        VStack(alignment: .leading) {
            Text(publicData.name)
        }
    }
    
    func buttons(characterInfo: CharacterInfoDisplayable) -> some View {
        VStack {
            Button(action: {
                self.viewModel.updateCharacterWallet(characterId: characterInfo.characterID)
            }, label: {
                Text("Update Wallet")
            }).buttonStyle(.glass)
            
            Button(action: {
                self.viewModel.updateCharacterAssets(characterId: characterInfo.characterID)
            }, label: {
                Text("Update Assets")
            }).buttonStyle(.glass)
            
            Button(action: {
                self.viewModel.updateCharacterIndustry(characterId: characterInfo.characterID)
            }, label: {
                Text("Update Indy")
            }).buttonStyle(.glass)
            
            Button(action: {
                do {
                    try CharacterWalletModel.query(on: DataManager.shared.dbManager!.database)
                        .delete()
                        .wait()
                } catch let error {
                    print("delete wallet error \(error)")
                }
            }, label: {
                Text("Delete")
            }).buttonStyle(.glass)
        }
    }
    
    func df2so(_ price: Double) -> String{
            let numberFormatter = NumberFormatter()
            numberFormatter.groupingSeparator = ","
            numberFormatter.groupingSize = 3
            numberFormatter.usesGroupingSeparator = true
            numberFormatter.decimalSeparator = "."
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 2
            return numberFormatter.string(from: price as NSNumber)!
        }
}
