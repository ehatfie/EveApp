//
//  CharacterInfoView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/27/23.
//

import SwiftUI
import ModelLibrary

class CharacterInfoViewModel: ObservableObject {
  @Published var characterInfo: CharacterInfo?
  @Published var characterData: CharacterDataModel?
  @Published var characterPortraitUrl: URL?
  @Published var characters: [CharacterDataModel] = []
  
  init() {
    DataManager.shared
      .$characterData
      .assign(to: &$characterInfo)
    
    do {
      self.characterData = try CharacterDataModel
        .query(on: DataManager.shared.dbManager!.database)
        .with(\.$skillsData)
        .with(\.$industryJobsData)
        .first()
        .wait()
      let foo = self.characterData?.skillsData?.skills ?? []
      
      self.characters = DataManager.shared.dbManager?.getCharacters() ?? []
      
      print("got skills \(foo.count)")
    } catch let error {
      print("CharacterDataModel query error \(error)")
    }
    
  }
  
  func fetchCharacterCorps() {
    Task {
      await DataManager.shared.fetchCorporationInfoForCharacters()
    }
  }
  
  func fetchCharacterPortrait() {
    Task {
      do {
        //try await DataManager.shared.fetchCharacterIcons()
        let character = await DataManager.shared.dbManager!.getCharacters()[0]
        let response = try await DataManager.shared.fetchIcon(for: character)
        let url = URL(string: response?.px128x128 ?? "")
        //let data = try? Data(contentsOf: url!)
        DispatchQueue.main.async {
          self.characterPortraitUrl = url
        }
      } catch let err {
        print("Errr \(err)")
      }
    }
  }
  
  func fetchCharacterSkills() {
    Task {
      await DataManager.shared.fetchSkillsForCharacters()
      let foo = self.characterData?.skillsData?.skills ?? []
      print("got skills \(foo.count)")
    }
  }
  
  func fetchCharacterIndustryJobs() {
    Task {
      await DataManager.shared.fetchIndustryJobsForCharacters()
      
      let foo = self.characterData?.industryJobsData ?? []
      print("got industry jobs \(foo.count)")
    }
  }
}

struct CharacterInfoView: View {
  // the character info object
  @ObservedObject var viewModel = CharacterInfoViewModel()
  
  var body: some View {
    VStack(alignment: .leading) {
      CharacterInfoList(viewModel: CharacterInfoListViewModel(dbManager: DataManager.shared.dbManager!))
      HStack(alignment: .top, spacing: 10) {
        if let characterData = viewModel.characterData {
          VStack(alignment: .leading) {
            Text("characterId: \(characterData.characterId)")
            localDataView(characterData: characterData)
          }.frame(maxWidth: 250)
          if let skillsData = viewModel.characterData?.skillsData {
            VStack {
              Text("Skills Info")
              CharacterSkillsView(characterModel: characterData,skillsData: skillsData)
            }
          }
        }
        Spacer()
//        VStack(alignment: .leading) {
//          if let characterData = self.$viewModel.characterInfo.wrappedValue {
//            Text("characterId: \(characterData.characterID)")
//            if let publicData = characterData.publicData {
//              getPublicCharacterDataView(characterPublicData: publicData)
//            }
//          } else {
//            Text("No Character info found")
//          }
//          
//        }
      }
      HStack {
        Button(action: {
          DataManager.shared.fetchCharacterInfo()
        }, label: {
          Text("get character info")
        })
        
        Button(action: {
          viewModel.fetchCharacterCorps()
        }, label: {
          Text("get corporation info")
        })
        
        Button(action: {
          viewModel.fetchCharacterPortrait()
        }, label: {
          Text("get character portrait")
        })
        
        Button(action: {
          viewModel.fetchCharacterSkills()
        }, label: {
          Text("get character skills")
        })
        
        Button(action: {
          viewModel.fetchCharacterIndustryJobs()
        }, label: {
          Text("get industry jobs")
        })
      }
    }
    .frame(minWidth: 250)
    .border(.red)
  }
  
  func getPublicCharacterDataView(characterPublicData data: CharacterPublicDataResponse) -> VStack<some View> {
    return VStack(alignment:.leading, spacing: 10) {
      Text(data.name)
      Text(data.birthday ?? "NO_BIRTHDAY")
      Text(data.description ?? "")
      Text("\(data.security_status ?? 0.0)")
      Text(data.title ?? "")
    }
  }
  
  @ViewBuilder
  func localDataView(characterData: CharacterDataModel) -> some View {
    VStack {
      if let imageURL = self.viewModel.characterPortraitUrl {
        AsyncImage(url: imageURL)
      }
      if let publicData = try? characterData.$publicData
        .get(on: DataManager.shared.dbManager!.database)
        .wait()
      {
        VStack(alignment:.leading, spacing: 10) {
          lineItem(
            primary: publicData.name,
            secondary: publicData.title ?? ""
          )
          lineItem(
            primary: "Birthday",
            secondary: publicData.birthday
          )
          
          lineItem(
            primary: "Description ", 
            secondary: publicData.description ?? ""
          )
          
          lineItem(
            primary: "SEC Status",
            secondary: "\(publicData.securityStatus ?? 0.0)"
          )
          lineItem(
            primary: "Corp ID",
            secondary: "\(publicData.corporationId)"
          )

        }
      }

    }
  }
  
  func lineItem(primary: String, secondary: String) -> some View {
    HStack(alignment: .top) {
      Text(primary)
      Text(secondary)
      Spacer()
    }
  }
  
}

struct CharacterInfoView_Previews: PreviewProvider {
  static var previews: some View {
    CharacterInfoView()
  }
}
