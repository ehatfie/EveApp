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
    
    init(dbManager: DBManager) {
        self.dbManager = dbManager

        Task {
            await loadCharacters()
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
        }
    }
    
    @ViewBuilder
    func characterInfoCard(_ characterInfo: CharacterInfoDisplayable) -> some View {
        GroupBox {
            VStack {
                Text(characterInfo.name)
                if let walletModel = characterInfo.walletModel {
                    Text(df2so(walletModel.$balance.wrappedValue ?? 0.00) + " ISK")
                }
                Button(action: {
                    self.viewModel.updateCharacterWallet(characterId: characterInfo.characterID)
                }, label: {
                    Text("Update Wallet")
                })
                
                Button(action: {
                    self.viewModel.updateCharacterAssets(characterId: characterInfo.characterID)
                }, label: {
                    Text("Update Assets")
                })
                
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
                })
            }
        }

    }
    
    @ViewBuilder
    func characterPublicData(_ publicData: CharacterPublicDataModel) -> some View {
        VStack(alignment: .leading) {
            
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
