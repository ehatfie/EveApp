//
//  IndustryPlanInfoView.swift
//  EveApp
//
//  Created by Erik Hatfield on 1/7/24.
//

import SwiftUI

struct IndustryPlanInfoView: View {
  let inputMaterialInfo: InputMaterialInfo
  
  var body: some View {
    return VStack(alignment: .leading) {
      HStack {
        Text(inputMaterialInfo.typeModel.name)
        Text("\(inputMaterialInfo.quantity)")
      }.font(.title3)
      
      if let bp = inputMaterialInfo.blueprintModel {
        testFunc()
      }
      
      Divider()
      ForEach(inputMaterialInfo.inputs, id: \.typeModel.typeId) { input in
        IndustryPlanInfoView(inputMaterialInfo: input)
          .padding(.leading, 10)
      }
    }
  }
  
  func testFunc() -> some View {
    let manufacturing = inputMaterialInfo.blueprintModel!.blueprintModel.activities.manufacturing
    let reactions = inputMaterialInfo.blueprintModel!.blueprintModel.activities.reaction
    let productInfo = manufacturing.products.first ?? reactions.products.first ?? QuantityTypeModel(quantity: 0, typeId: 0)
    
    return VStack {
      HStack {
        Text("makes \(productInfo.quantity)")
        
      }
    }
  }
}
#Preview {
  IndustryPlanInfoView(
    inputMaterialInfo: InputMaterialInfo(
      typeModel: TypeModel(typeId: 0, data: TypeData(groupID: 0, portionSize: 0, published: false)),
      quantity: 0,
      blueprintModel: nil,
      inputs: []
    )
  )
}
