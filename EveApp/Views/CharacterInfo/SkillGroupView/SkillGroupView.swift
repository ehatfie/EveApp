//
//  SkillGroupView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/20/24.
//

import SwiftUI
import TestPackage1

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
                //EqualWidthLayout {
                VStack(alignment: .center, spacing: 5) {
                    //EqualWidthLayout {
                        ForEach(skillGroup.skills, id: \.id) { skill in
                            SkillGroupEntryView(skill: skill)
                        }
                   // }
                   // }//.padding(.vertical, 1)
                }.padding(.horizontal, 5)
            }
            Spacer()
        }
        //.frame(maxWidth: .infinity)
        .onTapGesture {
            expanded.toggle()
        }
    }
    
}

#Preview {
    SkillGroupView(skillGroup: SkillGroup(group: GroupModel(), skills: []))
}
