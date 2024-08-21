//
//  BlueprintComponentListView.swift
//  EveApp
//
//  Created by Erik Hatfield on 1/2/24.
//

import SwiftUI
import TestPackage1

struct BlueprintComponentListView: View {
  var listData: BlueprintComponentListData
  
  var body: some View {
    VStack(alignment: .leading, spacing: 10){
      Text(listData.groupName)
        .font(.title2)
      
      VStack(alignment: .leading, spacing: 10) {
        ForEach(listData.items, id: \.id) { item in
          BlueprintComponentListRowView(data: item)
        }
      }
    
    }
  }
}

struct BlueprintComponentListRowView: View {
  @State var shouldExpand: Bool = false
  var data: BlueprintComponentDataDisplayable
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(data.typeModel.name)
        
        Spacer()
        
        Text("\(data.quantityType.quantity)")
      }
      
      if shouldExpand {
        VStack {
          Text("Hello world")
        }
      }
      
    }.frame(maxWidth: 250)
      .onTapGesture {
        shouldExpand.toggle()
      }
  }
}

#Preview {
  BlueprintComponentListView(
    listData: BlueprintComponentListData(
      group: GroupModel(
        groupId: 0,
        groupData: GroupData(
          id: 0, name: "name"
        )
      ),
      items: []
    )
  )
}
