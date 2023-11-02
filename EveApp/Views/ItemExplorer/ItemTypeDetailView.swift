//
//  ItemDetailView.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import SwiftUI

struct ItemTypeDetailView: View {
    let typeModel: TypeModel
    
    var body: some View {
        VStack {
            Text("HELLO WORLD")
            Text(typeModel.name)
        }
    }
}

//#Preview {
//    ItemTypeDetailView(typeModel: TypeModel(typeId: 0, data: TypeData(from: nil)))
//}
