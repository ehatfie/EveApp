//
//  CharacterInfoView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/27/23.
//

import SwiftUI

class CharacterInfoViewModel: ObservableObject {
    @Published var characterInfo: CharacterInfo?
    
    init() {
        DataManager.shared
            .$characterData
            .assign(to: &$characterInfo)
    }
}

struct CharacterInfoView: View {
    // the character info object
    @ObservedObject var viewModel = CharacterInfoViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                if let characterData = self.$viewModel.characterInfo.wrappedValue {
                    Text("characterId: \(characterData.characterID)")
                    if let publicData = characterData.publicData {
                        getPublicCharacterDataView(characterPublicData: publicData)
                    }
                }
            }
            HStack {
                Button(action: {
                    DataManager.shared.fetchCharacterInfo()
                }, label: {
                    Text("get character info")
                })
            }
        }
        .frame(minWidth: 250)
        .border(.red)
    }
    
    func getPublicCharacterDataView(characterPublicData data: CharacterPublicDataResponse) -> VStack<some View> {
        return VStack(alignment:.leading, spacing: 10) {
            Text(data.name)
            Text(data.birthday)
            Text(data.description ?? "")
            Text("\(data.security_status ?? 0.0)")
            Text(data.title ?? "")
        }
    }
}

struct CharacterInfoView_Previews: PreviewProvider {
    static var previews: some View {
        CharacterInfoView()
    }
}
