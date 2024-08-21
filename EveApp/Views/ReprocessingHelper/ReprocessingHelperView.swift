//
//  ReproccessingHelper.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/6/23.
//

import SwiftUI
import Fluent
import TestPackage1

struct ReprocessingHelperView: View {
  @State var materials: [TypeModel]
  
  
  init() {
    let db = DataManager.shared.dbManager!.database
    let materialTypes = try! TypeModel
      .query(on: db)
      .filter(\.$groupID == 18)
      .filter(\.$published == true)
      .filter(\.$typeId != 48927)
      .filter(\.$typeId != 76374)
      .all()
      .wait()
    
    materials = materialTypes
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Spacer()
        Text("Industry Helper View ")
        Spacer()
      }.border(.red)
      
      HStack {
//        VStack {
//          materialInput(materials: materials)
//            .border(.green)
//          Spacer()
//        }
        VStack {
          BlueprintIndustryView()
            .border(.blue)
          Spacer()
        }
        //ReactionsHelperView()
        //Spacer()
      }
      
    }
  }
  
  func materialInput(materials: [TypeModel]) -> some View {
    return VStack(alignment: .leading) {
      ForEach(materials, id: \.typeId) { material in
        HStack {
          Text(material.name)
          Spacer()
          TextField(
            "",
            value: Binding<String>(
              get: { "" },
              set: { result in
                setMaterialValue(id: material.typeId, value: result)
              }
            ), formatter: NumberFormatter()
          ).frame(width: 100)
        }
      }
    }.frame(width: 200)
      .padding(20)
  }
  
  func setMaterialValue(id: Int64, value: String) {
    print("set material: \(id) value: \(value)")
  }
}


#Preview {
  ReprocessingHelperView()
}


/**
 
 list of materials we want
 
 */


