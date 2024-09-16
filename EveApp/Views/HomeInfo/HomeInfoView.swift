//
//  HomeInfoView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/5/24.
//

import SwiftUI
import Fluent
import ModelLibrary

class CharacterInfoData: Identifiable{
  var id: String {
    self.characterDataModel.characterId
  }
  let characterDataModel: CharacterDataModel
  let publicData: CharacterPublicDataModel?
  let corporationData: CorporationInfoModel?
  
  init(characterDataModel: CharacterDataModel, publicData: CharacterPublicDataModel?, corporationData: CorporationInfoModel?) {
    self.characterDataModel = characterDataModel
    self.publicData = publicData
    self.corporationData = corporationData
  }
  
  static func == (lhs: CharacterInfoData, rhs: CharacterInfoData) -> Bool {
    return lhs.characterDataModel.characterId == rhs.characterDataModel.characterId
  }
}

@Observable final class HomeInfoViewModel {
  var dbManager: DBManager
  var characterInfo = [CharacterInfoData]()
  
  init(dbManager: DBManager) {
    self.dbManager = dbManager
    
    getCharacterInfo()
  }
  
  func getCharacterInfo() {
    Task {
      let characterInfo = await self.dbManager.getCharactersWithInfo()
      characterInfo.forEach { print("getCharacterInfo \($0.corp.count)")}
      let values = characterInfo.map {
        CharacterInfoData(
          characterDataModel: $0,
          publicData: $0.publicData,
          corporationData: $0.corp.first
        )
      }
      
      DispatchQueue.main.async {
        print("got characterInfo \(characterInfo.count)")
        self.characterInfo = values//characterInfo
      }
    }
  }
  
  func getCorpInfo() {
    Task {
      await DataManager.shared.fetchCorporationInfoForCharacters()
    }
  }
}

struct HomeInfoView: View {
  @Environment(DBManager.self) var dbManager
  let viewModel: HomeInfoViewModel
  // Here we want to display info on characters fetched
    var body: some View {
      VStack(alignment: .center) {
        Text("HomeInfoView")

        CharacterInfoView1(characterInfo: viewModel.characterInfo)
          .border(.red)
          .padding()
        
        Spacer()
        
        VStack {
          //getCorpInfoButton()
        }
      }
    }
  
  func getCorpInfoButton() -> some View {
    VStack {
      Button(action: {
        viewModel.getCorpInfo()
      }, label: {
        Text("Get Corp Info")
      })
    }
  }
}

#Preview {
    HomeInfoView(viewModel: HomeInfoViewModel(dbManager: DBManager()))
}
