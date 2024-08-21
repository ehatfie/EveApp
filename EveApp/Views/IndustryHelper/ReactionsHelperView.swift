//
//  ReactionsHelperView.swift
//  EveApp
//
//  Created by Erik Hatfield on 1/2/24.
//

import SwiftUI
import TestPackage1

struct ReactionsHelperView: View {
  var items: [TypeModel]
  
  @State var selectedBlueprint: TypeModel?
  
  init() {
    let reactionBlueprints = DataManager.shared.dbManager!.getReactionBlueprints()
    print("Reactions helper view got \(reactionBlueprints.count) reaction blueprints")
    items = reactionBlueprints
  }
  
  var body: some View {
    VStack {
      
      Text("Reactions Helper View")
      
      List(items, id: \.typeId) { type in
        reactionFormulaRow(type)
          .padding([.top, .bottom], 5)
          .onTapGesture {
            self.selectedBlueprint = type
          }
      }
      
      VStack {
        Text("Selected thing")
        
        if let selectedType = self.selectedBlueprint,
           let blueprintModel = try? selectedType.joined(BlueprintModel.self)
        {
          blueprintDetailView(blueprintModel)
        }
        
        Spacer()
      }
      
      Spacer()
    }
  }
  
  func reactionFormulaRow(_ typeModel: TypeModel) -> some View {
    return VStack(alignment: .leading) {
      Text(typeModel.name)
    }
  }
  
  func blueprintDetailView(_ blueprintModel: BlueprintModel) -> some View {
    let activities = blueprintModel.activities
    let reaction = activities.reaction
    let materials = reaction.materials
    let types = DataManager.shared.dbManager!.getTypes(for: materials.map { $0.typeId })
    
    return VStack {
      ForEach(types, id: \.typeId) { type in
        Text(type.name)
      }
      Text("material input count \(materials.count)")
    }
  }
}

#Preview {
  ReactionsHelperView()
}


/**
 
 want to be able to see all reactions
 */
