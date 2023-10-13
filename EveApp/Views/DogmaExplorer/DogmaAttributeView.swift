//
//  DogmaAttributeView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/12/23.
//

import SwiftUI

struct DogmaAttributeView: View {
    @Binding var dogmaAttribute: DogmaAttributeModel
    
    
    var body: some View {
        VStack {
            Text(dogmaAttribute.name)
            Text(dogmaAttribute.attributeDescription ?? "")
        }
        
    }
}

#Preview {
    DogmaAttributeView(dogmaAttribute: Binding(get: {
        DogmaAttributeModel()
    }, set: { _ in     }))
}
