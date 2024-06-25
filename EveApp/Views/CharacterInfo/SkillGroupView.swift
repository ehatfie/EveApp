//
//  SkillGroupView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/20/24.
//

import SwiftUI

struct SkillGroupView: View {
    let skillGroup: SkillGroup
    @State var expanded = false
    var body: some View {
        
            
            
            VStack(alignment: .leading) {
                HStack {
                    Text("\(skillGroup.group.name)")
                        .font(.headline)
                    Spacer()
                }
                
                if expanded {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(skillGroup.skills, id: \.id) { skill in
                            HStack {
                                //EqualWidthLayout {
                                Text(skill.typeModel.name)
                                Text("\(skill.skillModel.activeSkillLevel)")
                                Text("\(skill.skillModel.trainedSkillLevel)")
                                Text("\(skill.skillModel.skillpointsInSkill)")
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 1)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .onTapGesture {
                expanded.toggle()
            }.border(.blue)
        }
    
}

#Preview {
    SkillGroupView(skillGroup: SkillGroup(group: GroupModel(), skills: []))
}
