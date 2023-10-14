//
//  DogmaAttributeDetailView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/13/23.
//

import SwiftUI

struct DogmaAttributeDetailView: View {
  @Binding var dogmaAttribute: DogmaAttributeModel
  
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text("\(dogmaAttribute.attributeID)")
        Text(dogmaAttribute.name)
      }
      
      Text(dogmaAttribute.attributeDescription ?? "NO VALUE")
    }
  }
}

#Preview {
  DogmaAttributeDetailView(
    dogmaAttribute:
      Binding(get: {
        DogmaAttributeModel()
      }, set: { _ in } ))
}

//#Preview {
//    DogmaAttributeView(dogmaAttribute: Binding(get: {
//        DogmaAttributeModel()
//    }, set: { _ in     }))
//}
