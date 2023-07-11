//
//  SkillQueueView.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/3/23.
//

import SwiftUI

class SkillQueueViewModel: ObservableObject {
    @Published var characterInfo: CharacterInfo?
    
    init() {
        DataManager.shared
            .$characterData
            .assign(to: &$characterInfo)
    }
    
    func fetchSkillQueue() {
        DataManager.shared.fetchSkillQueue()
    }
}

struct SkillQueueView: View {
    @ObservedObject var viewModel: SkillQueueViewModel
    var body: some View {
        VStack {
            Text("Skill queue view")
            Button(action: {
                viewModel.fetchSkillQueue()
            }, label: {
                Text("Fetch")
            })
            
            if let skillQueue = $viewModel.characterInfo.wrappedValue?.skillQueue {
                ForEach(skillQueue) { queue in
                    Text("\(queue.skill_id)")
                }
            }
        }
    }
}

struct SkillQueueView_Previews: PreviewProvider {
    static var previews: some View {
        SkillQueueView(viewModel: SkillQueueViewModel())
    }
}
