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
        let start = Date()
        _ = await dbManager.getCharacters()
        let took1 = Date().timeIntervalSince(start)
        print("getCharacters took \(took1)")
        let characterInfo = await dbManager.getCharactersWithInfo()
        characterModels = characterInfo
        self.characterInfoDisplayables = await dbManager.getCharacterInfoDisplayable()

        
        let took2 = Date().timeIntervalSince(start) - took1
        print("getCharactersWithInfo took \(took2)")
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
            ForEach(viewModel.characterInfoDisplayables) { characterInfo in
                characterInfoCard(characterInfo)
            }
        }
    }
    
    @ViewBuilder
    func characterInfoCard(_ characterInfo: CharacterInfoDisplayable) -> some View {
        VStack {
            Text(characterInfo.characterID)
        }
    }
    
    @ViewBuilder
    func characterPublicData(_ publicData: CharacterPublicDataModel) -> some View {
        VStack(alignment: .leading) {
            
        }
    }
}
