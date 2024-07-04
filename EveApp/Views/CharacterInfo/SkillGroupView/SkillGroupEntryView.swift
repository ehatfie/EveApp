//
//  SkillGroupEntryView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/24/24.
//

import SwiftUI

// Could use a better name
struct SkillGroupEntryView: View {
    let skill: SkillInfo
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(skill.typeModel.name)
                    .font(.headline)
                Text("\(skill.skillModel.trainedSkillLevel) / 5")
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    if let info = skill.skillDogmaInfo?.skillMiscAttributes {
                        Text("\(info.primaryAttribute.name.capitalized) / \(info.secondaryAttribute.name.capitalized)")
                    }
                    
                    HStack(alignment: .top) {
                        if let info = skill.skillDogmaInfo?.skillMiscAttributes {
                            Text("\(skill.skillModel.skillpointsInSkill) / \(info.skillTimeConstant * 256000)")
                            Text("x\(info.skillTimeConstant)")
                        } else {
                            Text("\(skill.skillModel.skillpointsInSkill)")
                        }
                    }
                }
                
                Text(skill.typeModel.descriptionString ?? "")
            }

        }
        .padding()
        .background(Color(red: 102/255, green: 98/255, blue: 98/255))
        .cornerRadius(10)
        .padding()
    }
}

#Preview {
    SkillGroupEntryView(
        skill: SkillInfo(
            skillModel: CharacterSkillModel(
                activeSkillLevel: 5,
                skillId: 100,
                skillPointsInSkill: 100,
                trainedSkillLevel: 5),
            typeModel:  TypeModel(
                typeId: 0,
                data: TypeData(
                    groupID: 0,
                    name: ThingName(name: "Test Name"),
                    published: false
                )
            ), dogma: TypeDogmaInfoModel(
                typeId: 0,
                data: TypeDogmaData (
                    dogmaAttributes: [],
                    dogmaEffects: []
                )
            ), skillDogmaInfo: SkillDogmaAttributeInfo(
                skillMiscAttributes: SkillMiscAttributes(
                    primaryAttribute: DogmaAttributeModel(
                        attributeId: 0,
                        data: DogmaAttributeData1(attributeID: 0, defaultValue: 0, description: nil, name: "")
                    ),
                    secondaryAttribute: DogmaAttributeModel(
                        attributeId: 0,
                        data: DogmaAttributeData1(attributeID: 0, defaultValue: 0, description: nil, name: "")
                    ),
                    skillTimeConstant: 0
                )
            ), skillEffectInfo: SkillEffectInfo(
                skillDogmaEffectInfos: []
            ), skillDescription: ""
        )
    )
}
