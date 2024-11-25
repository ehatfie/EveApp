//
//  Displayable.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/30/24.
//

import Foundation
import ModelLibrary

struct IndustryJobDisplayable: Identifiable {
    var id: Int {
        return industryJobModel.jobId
    }
    let industryJobModel: CharacterIndustryJobModel
    let blueprintName: String  // = try await getBlueprintName(blueprintId)
    let blueprintLocationName: String  // = try await getBlueprintLocationName(locationId)
    let productName: String?
    
    init(
        industryJobModel: CharacterIndustryJobModel,
        blueprintName: String,
        blueprintLocationName: String,
        productName: String?
    ) {
        self.industryJobModel = industryJobModel
        self.blueprintName = blueprintName
        self.blueprintLocationName = blueprintLocationName
        self.productName = productName
    }
}

struct AssetInfoDisplayable {
  let asset: CharacterAssetsDataModel
  let typeModel: TypeModel
}

struct TypeQuantityDisplayable {
  var id: Int64 {
    typeModel.typeId
  }
  let quantity: Int64
  let typeModel: TypeModel
}

struct TypeNameDisplayable {
  let id: Int64
  let name: String
}

struct BlueprintComponentDataDisplayable: Identifiable {
  var id: Int
  let typeModel: TypeModel
  let quantityType: QuantityType
  
  init(typeModel: TypeModel, quantityTypeModel: QuantityTypeModel) {
    self.id = Int(typeModel.typeId)
    self.typeModel = typeModel
    self.quantityType = QuantityType(quantityTypeModel)
  }
  
  init(typeModel: TypeModel, quantityTypeModel: MaterialDataModel) {
    self.id = Int(typeModel.typeId)
    self.typeModel = typeModel
    self.quantityType = QuantityType(quantityTypeModel)
  }
}

struct ItemInfoDisplayable: Identifiable {
  let id: UUID = UUID()
  let typeDogmaInfoModel: TypeDogmaInfoModel
  let typeModel: TypeModel
}

struct ItemComponentDataDisplayable: Identifiable {
  var id: Int
  let typeModel: TypeModel
  let quantity: Int64
  // need to be able to tell how many this originally was
  let materials: [BlueprintComponentDataDisplayable]
  
  init(typeModel: TypeModel, materials: [BlueprintComponentDataDisplayable]) {
    self.id = Int(typeModel.typeId)
    self.typeModel = typeModel
    self.quantity = 0
    self.materials = materials
  }
  
  init(data: BlueprintComponentDataDisplayable, materials: [BlueprintComponentDataDisplayable]) {
    self.id = Int(data.typeModel.typeId)
    self.typeModel = data.typeModel
    self.quantity = data.quantityType.quantity
    self.materials = materials
  }
  
  //  init(typeModel: TypeModel, quantityTypeModel: MaterialDataModel) {
  //    self.id = Int(typeModel.typeId)
  //    self.typeModel = typeModel
  //    self.quantityType = QuantityType(quantityTypeModel)
  //  }
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
