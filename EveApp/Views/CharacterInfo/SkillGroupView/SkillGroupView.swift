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
                        SkillGroupEntryView(skill: skill)
                    }
                }.frame(maxWidth: 400)
                .padding(.horizontal, 10)
                .padding(.vertical, 1)
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
