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
        VStack(alignment: .leading, spacing: 24) {
            Text(skill.typeModel.name)
            Text(skill.typeModel.descriptionString ?? "")
           // Text("attribute count: \(skill.dogma.attributes.count)")
//            VStack(alignment: .leading, spacing: 2) {
//                ForEach(skill.dogma.attributes, id: \.attributeID) { attribute in
//                    Text("\(attribute.attributeID): \(attribute.value)")
//                }
//            }

            if let info = skill.skillDogmaInfo?.skillMiscAttributes {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Primary Attribute: \(info.primaryAttribute.name)")
                    Text("Secondary Attribute: \(info.secondaryAttribute.name)")
                }
               
            }
//            if !skill.skillEffectInfo.skillDogmaEffectInfos.isEmpty {
//                VStack(alignment: .leading, spacing: 6) {
//                //Text("Effects:")
//                    ForEach(skill.skillEffectInfo.skillDogmaEffectInfos, id: \.dogmaEffectModel.effectID) { effectInfo in
//                        if !effectInfo.effectedAttributes.isEmpty {
//                            VStack(alignment: .leading, spacing: 3) {
//                                ForEach(effectInfo.effectedAttributes, id: \.id) { dogmaAttribute in
//                                    if let skillDescription = dogmaAttribute.skillDescription {
//                                        Text(skillDescription)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }.border(.red)
//            }
//            ForEach(skill.dogma.effects, id: \.effectID) { effect in
//                Text("\(effect.effectID)")
//            }
            HStack(spacing: 10) {
                Text("\(skill.skillModel.trainedSkillLevel) / 5")
                Text("\(skill.skillModel.skillpointsInSkill)")
                
                if let info = skill.skillDogmaInfo?.skillMiscAttributes {
                    Text("x\(info.skillTimeConstant)")
                }
            }
        }
        .padding()
        .border(.black)
        .cornerRadius(1)
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
