//
//  MaterialDetailView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/28/23.
//

import SwiftUI
import Fluent

struct MaterialDetailView: View {
  var types: [TypeModel]
  var materials: [QuantityTypeModel]
  
  var listData: [(TypeModel, QuantityTypeModel)]
  
  let title: String
  
  init(title: String, materials: [QuantityTypeModel]) {
    self.title = title
    //materials.map({$0.typeId})
    let typeIds = materials.map({$0.typeId})
    print("checking against \(typeIds)")
//    let names = try! TypeModel.query(on: DataManager.shared.dbManager!.database)
//      .filter(\.$typeId == typeIds[0])
//      .all()
//      .wait()
    
    let types = materials.compactMap { value in
      try? TypeModel.query(on: DataManager.shared.dbManager!.database)
        .filter(\.$typeId == value.typeId)
        .first()
        .wait()
    }
    
    let listData = types
      .enumerated()
      .map { index, value in
        return (value, materials[index])
      }
    
    print("got \(types.count)")
    print("got listData \(listData.count)")
    self.materials = materials
    self.types = types
    
    self.listData = listData
  }
 
  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      Text(title)
        .font(.title2)
     
      Divider()
        
      
      VStack(alignment: .center) {
        HStack {
          VStack(alignment: .leading) {
            ForEach(types, id: \.typeId) { type in
              Text(type.name)
                .padding(.vertical, 2)
            }
          }
          Spacer()
          VStack(alignment: .trailing) {
            ForEach(materials, id: \.typeId) { material in
              Text("\(material.quantity)")
                .padding(.vertical, 2)
            }
          }
          
        }
      }

    }
    .fixedSize(horizontal: true, vertical: false)
    .padding(5)
  }
  
  func materialList() -> some View {
    VStack(alignment: .leading) {
      ForEach(listData, id: \.0.typeId) { value in
        HStack {
          Text("\(value.0.name)")
          Text("\(value.1.quantity)")
        }
      }
    }
  }
}

#Preview {
  MaterialDetailView(title: "Test Title", materials: [])
}
