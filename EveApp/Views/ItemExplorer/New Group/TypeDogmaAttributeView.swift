//
//  TypeDogmaAttributeView.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/15/23.
//

import SwiftUI
import Fluent
import ModelLibrary

struct TypeDogmaAttributeView: View {
    let dogmaAttribute: TypeDogmaAttribute
    let dogmaAttributeModel: DogmaAttributeModel
    
    //    init(_ dogmaAttribute: TypeDogmaAttribute) {
    //        self.dogmaAttribute = dogmaAttribute
    //        let db = DataManager.shared.dbManager!.database
    //
    //        let dogmaAttributeModel = try! DogmaAttributeModel.query(on: db).sort(\.$attributeID)
    //            .filter(\.$attributeID == dogmaAttribute.attributeID)
    //          .first()
    //          .wait()
    //
    //        self.dogmaAttributeModel = dogmaAttributeModel!
    //    }
    
    init(data: AttributeDisplayable) {
        self.dogmaAttribute = data.typeDogmaAttribute
        self.dogmaAttributeModel = data.dogmaAttributeModel
        
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(dogmaAttributeModel.name)")
                Text("\(dogmaAttribute.value)")
                
            }
            Text("defaultValue \(dogmaAttributeModel.defaultValue)")
            Text("data type \(dogmaAttributeModel.dataType)")
            Text(dogmaAttributeModel.attributeDescription ?? "")
            Text("category \(dogmaAttributeModel.categoryID ?? -1)")
        }
    }
}

#Preview {
    TypeDogmaAttributeView(
        data: AttributeDisplayable(
            typeDogmaAttribute: TypeDogmaAttribute(
                data: DogmaAttributeInfo(
                    attributeID: 0,
                    value: 0
                )),
            dogmaAttributeModel: DogmaAttributeModel()
            
        )
    )
}
