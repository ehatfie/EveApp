//
//  SkillGroupEntryView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/24/24.
//

import SwiftUI
import TestPackage1

// Could use a better name
struct SkillGroupEntryView: View {
    let skill: SkillInfo
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GroupBox(content: {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(skill.typeModel.name)
                            .font(.headline)
                        Text("\(skill.skillModel.trainedSkillLevel) / 5")
                        Spacer()
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
            })
            .groupBoxStyle(CustomGroupBoxStyle())
        }
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

struct CustomGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .padding()
        .background(Color.pink.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        //.clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
