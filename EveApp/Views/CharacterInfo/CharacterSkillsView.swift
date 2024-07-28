//
//  CharacterSkillsView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/20/24.
//

import SwiftUI

struct SkillsDataRepresentable {
    let skillsData: CharacterSkillsDataModel
}

struct SkillGroup {
    let group: GroupModel
    let skills: [SkillInfo]
}

struct SkillInfo: Identifiable {
    var id: Int64 {
        typeModel.typeId
    }
    
    let skillModel: CharacterSkillModel
    let typeModel: TypeModel
    let dogma: TypeDogmaInfoModel
    let skillDogmaInfo: SkillDogmaAttributeInfo?
    let skillEffectInfo: SkillEffectInfo
    let skillDescription: String
}

@Observable
class CharacterSkillViewModel {
    var characterModel: CharacterDataModel
    var skillGroups: [SkillGroup] = []
    
    init(characterModel: CharacterDataModel) {
        self.characterModel = characterModel
        Task {
            await makeSkillGroups()
        }
    }
    
    func makeSkillGroups() async {
        let skillGroups = await DataManager.shared.dbManager!.getSkillGroups(for: characterModel.characterId)
        DispatchQueue.main.async {
            self.skillGroups = skillGroups
        }
    }
}

struct CharacterSkillsView: View {
    let characterModel: CharacterDataModel
    let skillsData: CharacterSkillsDataModel
    let viewModel: CharacterSkillViewModel
    
    init(characterModel: CharacterDataModel, skillsData: CharacterSkillsDataModel) {
        self.characterModel = characterModel
        self.skillsData = skillsData
        // get skill categories
        let skillIds = skillsData.skills.map { Int64($0.skillId) }
        self.viewModel = CharacterSkillViewModel(characterModel: characterModel)
       // self.skillsData = skillsData
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Character Skills View")
            VStack(alignment: .leading) {
                HStack {
                    Text("Total SP: \(skillsData.totalSp)")
                    Text("unallocated SP: \(skillsData.unallocatedSp ?? 0)")
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(
                            viewModel.skillGroups,
                            id: \.group.groupId
                        ) { skillGroup in
                            SkillGroupView(skillGroup: skillGroup)
                            Rectangle()
                                .frame(height: 1)
                                .background(.black)
                        }
                    }
                }
            }
                
        }.frame(maxWidth: .infinity)
        
    }
}

//#Preview {
//    CharacterSkillsView(
//        skillsData: CharacterSkillsDataModel(
//            characterId: "",
//            data: .init(
//                skills: [
//                    .init(
//                        activeSkillLevel: 5,
//                        skillId: 5,
//                        skillpointsInSkill: 0,
//                        trainedSkillLevel: 5
//                    )
//                ],
//                totalSp: 1000
//            )
//        )
//    )
//}
