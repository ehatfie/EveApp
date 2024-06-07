//
//  TypeInfoView.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/7/23.
//

import SwiftUI
import Fluent

struct TypeInfoView: View {
  @Binding var selectedType: TypeModel?
  
  var body: some View {
    VStack {
      Text("Type Info View")
      if let typeModel = selectedType {
        Text(typeModel.name + " \(typeModel.typeId)")
        typeInfo(for: typeModel)
        //industryInfo(for: typeModel)
      }
    }
    
  }
  
  @ViewBuilder
  func typeInfo(for typeModel: TypeModel) -> some View {
    let db = DataManager.shared.dbManager!.database
    let typeDogma = try! TypeDogmaInfoModel.query(on: db)
      .filter(\.$typeId == typeModel.typeId)
      .all()
      .wait()
    
    if let typeDogmaInfo = typeDogma.first {
      TypeDogmaInfoView(dogmaInfoModel: typeDogmaInfo)
    } else {
      Text("")
    }
    
  }
  
  @MainActor func industryInfo(for typeModel: TypeModel) -> some View {
    return ItemMaterialDetailView(
      viewModel: ItemMaterialDetailViewModel(typeModel: typeModel))
  }
}

#Preview {
  TypeInfoView(
    selectedType: Binding<TypeModel?>(
      get: { TypeModel() },
      set: { _ in }
    )
  )
}
