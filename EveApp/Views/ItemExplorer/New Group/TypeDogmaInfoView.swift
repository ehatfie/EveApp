//
//  TypeDogmaInfoView.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/7/23.
//

import SwiftUI
import Fluent
import ModelLibrary

struct TypeDogmaInfoView: View {
  var dogmaInfoModel: TypeDogmaInfoModel
  
  init(dogmaInfoModel: TypeDogmaInfoModel) {
    self.dogmaInfoModel = dogmaInfoModel
    
  }
  
  var body: some View {
    VStack {
      Text("Type Dogma Info View")
      HStack {
        attributeInfo()
        effectInfo()
      }
    }
  }
  
  func attributeInfo() -> some View {
    let attributes = dogmaInfoModel.attributes //.sorted(by: { })
    let attributeIds = attributes.map { $0.attributeID }
    //let values = DataManager.shared.dbManager!.getTypeNames(for: attributeIds)
    let db = DataManager.shared.dbManager!.database
    let things = try! DogmaAttributeModel.query(on: db).sort(\.$attributeID)
      .filter(\.$attributeID ~~ attributeIds)
      .all()
      .wait()
    
    let values = Array(zip(attributes, things))
      .sorted(by: { $0.1.categoryID ?? 99 < $1.1.categoryID ?? 99 })
      .map { AttributeDisplayable(typeDogmaAttribute: $0.0, dogmaAttributeModel: $0.1)}
    
    //print("got \(values.count) type names for \(attributeIds.count) attributes ")
    //let attributeNames
    return VStack {
      List(values, id: \.id) { value in
        TypeDogmaAttributeView(data: value)
      }
    }
  }
  
  func effectInfo() -> some View {
    let effects = dogmaInfoModel.effects
    let effectIds = effects.map { $0.effectID }
    let db = DataManager.shared.dbManager!.database
    let things = try! DogmaEffectModel.query(on: db)
      .filter(\.$effectID ~~ effectIds)
      .all()
      .wait()
    
    let types = try! TypeModel.query(on: db)
      .filter(\.$typeId ~~ effectIds.map {Int64($0)})
      .all()
      .wait()
    
    print("got \(types.count) types")
    
    let foo = Array(zip(effects, things)).map { EffectDisplayable(typeDogmaEffect: $0.0, dogmaEffectModel: $0.1)}
    
    return VStack {
//      ForEach(foo, id: \.0.effectID) { thing in
//        Text(thing.0.effectName + " \(thing.1.effectID)")
//      }
      List(foo, id: \.id) { value in
        VStack {
          Text(value.dogmaEffectModel.effectName)
          
        }
        
        
      }
    }
  }
}

struct EffectDisplayable: Identifiable {
  var id: Int64
  
  let typeDogmaEffect: TypeDogmaEffect
  let dogmaEffectModel: DogmaEffectModel
  
  init(typeDogmaEffect: TypeDogmaEffect, dogmaEffectModel: DogmaEffectModel) {
    self.id = typeDogmaEffect.effectID
    self.typeDogmaEffect = typeDogmaEffect
    self.dogmaEffectModel = dogmaEffectModel
  }
}

struct AttributeDisplayable: Identifiable {
  var id: Int64
  
  let typeDogmaAttribute: TypeDogmaAttribute
  let dogmaAttributeModel: DogmaAttributeModel
  
  init(typeDogmaAttribute: TypeDogmaAttribute, dogmaAttributeModel: DogmaAttributeModel) {
    self.id = typeDogmaAttribute.attributeID
    self.typeDogmaAttribute = typeDogmaAttribute
    self.dogmaAttributeModel = dogmaAttributeModel
  }
}

#Preview {
  TypeDogmaInfoView(dogmaInfoModel: TypeDogmaInfoModel(typeId: 0, data: TypeDogmaData(dogmaAttributes: [], dogmaEffects: [])))
}
