//
//  GroupInfoView.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/6/23.
//

import SwiftUI
import Fluent

struct GroupInfoView: View {
  @Binding var selectedGroup: GroupModel? // nextThing
  @Binding var selectedType: TypeModel?
  
  var body: some View {
    VStack {
      Text("Group Info View")
      if let groupModel = selectedGroup {
        Text(groupModel.name)
        itemList(groupModel: groupModel)
      }
      
      Spacer()
    }
    
  }
  
  // current data type, filter
  func itemList(groupModel: GroupModel) -> some View {
    let types = try! TypeModel
      .query(on: DataManager.shared.dbManager!.database)
      .filter(\.$groupID == groupModel.groupId)
      .filter(\.$published == true)
      .all()
      .wait()
    
    return List(types, id: \.typeId) { type in
      Text(type.name)
        .onTapGesture {
          selectedType = type
        }
    }.frame(maxWidth: 275)
  }
}

#Preview {
  CategoryInfoView(
    selectedCategory: Binding<CategoryModel?>(
      get: { CategoryModel() },
      set: { _ in }
    ),
    selectedGroup: Binding<GroupModel?>(
      get: { nil },
      set: { _ in }
    )
  )
}
