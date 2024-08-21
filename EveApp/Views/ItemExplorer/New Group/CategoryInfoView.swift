//
//  CategoryInfoView.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/6/23.
//

import SwiftUI
import Fluent
import TestPackage1

struct CategoryInfoView: View {
  @Binding var selectedCategory: CategoryModel?
  @Binding var selectedGroup: GroupModel?
  
  var body: some View {
    VStack {
      Text("CategoryInfoView")
      if let categoryModel = selectedCategory {
        HStack {
          Text(categoryModel.name)
          Text("\(categoryModel.categoryId)")
        }
        
        groupList(categoryModel: categoryModel)
      }
      
      Spacer()
    }
    
  }
  
  // current data type, filter
  func groupList(categoryModel: CategoryModel) -> some View {
    let groups = try! GroupModel
      .query(on: DataManager.shared.dbManager!.database)
      .filter(\.$categoryID == categoryModel.categoryId)
      .filter(\.$published == true)
      .all()
      .wait()
    
    return List(groups, id: \.groupId) { group in
      HStack {
        Text(group.name)
        Text("\(group.groupId)")
      }
        .onTapGesture {
          selectedGroup = group
        }
    }.frame(maxWidth: 200)
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
