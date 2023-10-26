//
//  BlueprintDetailView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/26/23.
//

import SwiftUI
import Fluent

struct BlueprintDetailView: View {
    var blueprint: BlueprintModel
    var typeModel: TypeModel?
    
    init(blueprint: BlueprintModel) {
        let db = DataManager.shared.dbManager!.database
        
        self.blueprint = blueprint
        
        let foo = try! TypeModel.query(on: db).filter(\.$typeId == blueprint.blueprintTypeID)
            .first().wait()
        self.typeModel = foo 
        
    }
    var body: some View {
        HStack {
            if let typeModel = self.typeModel {
                Text("\(typeModel.name)")
            }
        }
    }
}

//#Preview {
//    BlueprintDetailView()
//}
