//
//  CharacterInfoView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/5/24.
//

import SwiftUI
import TestPackage1

struct CharacterInfoView1: View {
  var characterInfo: [CharacterInfoData]
  
  var body: some View {
    VStack {
      ForEach(characterInfo, id: \.id) { characterInfo in
        if let publicData = characterInfo.publicData {
          VStack {
            Text(publicData.name)
            Text("\(publicData.securityStatus ?? 0.0)")
            Text("\(publicData.birthday)")
          }
        } else {
          Text("\(characterInfo.characterDataModel.characterId)")
        }
        
        if let corporationData = characterInfo.corporationData {
          VStack(alignment: .leading) {
            Text("\(corporationData.name)")
            Text("members: \(corporationData.memberCount)")
          }.padding()
        }
      }
    }
  }
  
  @ViewBuilder
  func publicDataView(_ publicData: CharacterPublicDataModel) -> some View {
    VStack {
      
      
    }
  }
}

#Preview {
  CharacterInfoView()
}
