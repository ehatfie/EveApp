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
    
    init(dbManager: DBManager) {
        self.dbManager = dbManager

        Task {
            await loadCharacters()
        }
    }
    
    func loadCharacters() async {
        let characterInfo = await dbManager.getCharactersWithInfo()
        characterModels = characterInfo
        self.characterInfoDisplayables = await dbManager.getCharacterInfoDisplayable()
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
    var viewModel: CharacterInfoListViewModel
    var body: some View {
        VStack {
            HStack {
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
                    Text(String(format: "%.2f",walletModel.$balance.wrappedValue ?? 0.00) + " isk")
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
}
