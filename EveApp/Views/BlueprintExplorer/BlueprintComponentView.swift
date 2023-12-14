//
//  BlueprintComponentView.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/1/23.
//

import SwiftUI
import Fluent
import FluentSQL

enum IndustryGroups: Int {
  case mineral = 18
  case constructionComponents = 334
}

struct BlueprintComponentView: View {
  var blueprintModel: BlueprintModel
  
  let typeModels: [BlueprintComponentDataDisplayable]
  let typeMaterials: [TypeMaterialsModel]
  let materialTypes: [TypeMaterialsModel]
  let listData: [BlueprintComponentListData]
  
  init(blueprintModel: BlueprintModel) {
    self.blueprintModel = blueprintModel
    
    let materials = blueprintModel.activities.manufacturing.materials
    let materialIds = materials.map { $0.typeId }
    
    let typeModels = materials.compactMap { value -> BlueprintComponentDataDisplayable? in
      guard let typeModel = try? TypeModel.query(on: DataManager.shared.dbManager!.database)
        .filter(\.$typeId == value.typeId)
        .first()
        .wait()
      else {
        return nil
      }
      
      // return ItemComponentDataDisplayable
      return BlueprintComponentDataDisplayable(typeModel: typeModel, quantityTypeModel: value)
    }.sorted(by: {$0.typeModel.groupID < $1.typeModel.groupID})
    
    let typeMaterials = materials.compactMap { value in
      try? TypeMaterialsModel.query(on: DataManager.shared.dbManager!.database)
        .filter(\.$typeID == value.typeId)
        .first()
        .wait()
    }
    
    var typeGroups: [Int64: [BlueprintComponentDataDisplayable]] = [:]
    
    typeModels.forEach { value in
      let existingValues = typeGroups[value.typeModel.groupID] ?? []
      typeGroups[value.typeModel.groupID] = existingValues + [value]
    }
    
    let listData = typeGroups.compactMap { key, value -> BlueprintComponentListData? in
      guard let group = DataManager.shared.dbManager!.getGroup(for: key) else {
        return nil
      }
      return BlueprintComponentListData(group: group, items: value)
    }
    
    self.listData = listData
    self.typeModels = typeModels
    self.typeMaterials = typeMaterials
    
    let materialTypes = DataManager.shared.dbManager?
      .getTypeMaterialModels(for: materialIds) ?? []
    self.materialTypes = materialTypes
    
    DataManager.shared.dbManager?.getTests(for: materialIds)
    self.getJobs(for: blueprintModel)
  }
  
  var body: some View {
    ScrollView {
      HStack(spacing: 30) {
        materialList()
        componentList()
        //      List(typeModels, id: \.id) { type in
        //        VStack {
        //          groupInfo(for: type.typeModel.groupID)
        //          Text(type.typeModel.name + " \(type.quantityTypeModel.quantity)")
        //        }
        //
        //      }
        //      List(materialTypes, id: \.typeID) { type in
        //        Text("\(type.typeID)")
        //      }
      }
    }
  }
  
  func materialList() -> some View {
    VStack(spacing: 10) {
      Text("Materials List")
        .font(.title2)
      ForEach(listData, id: \.id) { data in
        VStack(alignment: .leading, spacing: 10){
          Text(data.groupName)
            .font(.title2)
          VStack(alignment: .leading, spacing: 10) {
            ForEach(data.items, id: \.id) { item in
              HStack {
                Text(item.typeModel.name)
                Spacer()
                Text("\(item.quantityType.quantity)")
              }.frame(maxWidth: 250)
            }
          }//.border(.blue)
        }//.border(.red)
      }
      Spacer()
    }
  }
  
 
  
  func getInputBlueprints(for item: QuantityTypeModel) {
    // as long as this type has a blueprint, i.e. its not trit
    // could possibly use category/group?
    print("get input blueprints for itemId: \(item.typeId)")
    guard let blueprint = getBlueprint(for: item.typeId) else {
      print("in blueprint for itemId: \(item.typeId)")
      return
    }
    print("got blueprint \(blueprint.blueprintTypeID)")
    let inputNames = DataManager.shared.dbManager!
      .getTypeNames(for: blueprint.activities.manufacturing.materials.map{$0.typeId}).map({"\($0.typeId) - \($0.name)"})
    print("input names \(inputNames)")
    let inputBlueprints = blueprint.activities.manufacturing.materials.compactMap { getBlueprint(for: $0.typeId) }
    guard !inputBlueprints.isEmpty else {
      let name = DataManager.shared.dbManager!.getTypeNames(for: [item.typeId]).map({$0.name})
      let bpName = DataManager.shared.dbManager!.getTypeNames(for: [blueprint.blueprintTypeID]).map {$0.name}
      print("No input blueprints for item: \(item.typeId) - \(name) with blueprint \(blueprint.blueprintTypeID) - \(bpName)")
      return
    }
    
    let typeIds = inputBlueprints.map { $0.blueprintTypeID }
    print("blueprint typeIds \(typeIds)")
    
  }
  

  
  func componentList() -> some View {
    let results = listData.map { value in
      let typeIds = value.items.map { value in
        value.typeModel.typeId
      }
      
//      print("checking against \(typeIds)")
      let typeMaterials = DataManager.shared.dbManager!.getTypeMaterialModels(for: typeIds)
      let blueprints = try! BlueprintModel.query(on: DataManager.shared.dbManager!.database)
        .filter(\.$blueprintTypeID ~~ typeIds) //.join(TypeModel.self, on: \BlueprintModel.$blueprintTypeID == \TypeModel.$typeId)
        .all()
        .wait()
//      print("got \(typeMaterials.count) inputs")
      return typeMaterials
    }.flatMap {$0}
    
    
    let res2 = listData.map { value in
      return value.items
    }.flatMap {$0}
    
    
    let models2 = res2.compactMap { firstValue -> [ItemComponentDataDisplayable]? in
      let typeMaterials: [TypeMaterialsModel] = DataManager.shared.dbManager!.getTypeMaterialModels(for: [firstValue.quantityType.typeId])
      
      let foo = typeMaterials.compactMap { value -> ItemComponentDataDisplayable? in
        let bar = value.materialData.compactMap { value -> BlueprintComponentDataDisplayable? in
          guard let typeModel = try? TypeModel.query(on: DataManager.shared.dbManager!.database)
            .filter(\.$typeId == value.materialTypeID)
            .first()
            .wait()
          else {
            return nil
          }
          return BlueprintComponentDataDisplayable(typeModel: typeModel, quantityTypeModel: value)
        }
        
        return ItemComponentDataDisplayable(data: firstValue, materials: bar)
      }
      return foo
    }.flatMap { $0 }
    
    
    //    let typeModels = results.compactMap { value -> ItemComponentDataDisplayable? in
    //      guard let typeModel = try? TypeModel.query(on: DataManager.shared.dbManager!.database)
    //        .filter(\.$typeId == value.typeID)
    //        .first()
    //        .wait() else {
    //        return nil
    //      }
    //      let foo = value.materialData.compactMap { value -> BlueprintComponentDataDisplayable? in
    //        guard let typeModel = try? TypeModel.query(on: DataManager.shared.dbManager!.database)
    //          .filter(\.$typeId == value.materialTypeID)
    //          .first()
    //          .wait()
    //        else {
    //          return nil
    //        }
    //        return BlueprintComponentDataDisplayable(typeModel: typeModel, quantityTypeModel: value)
    //      }
    //
    //      return ItemComponentDataDisplayable(typeModel: typeModel, materials: foo)
    //    }.sorted(by: {$0.typeModel.groupID < $1.typeModel.groupID})
    
    
    return VStack(alignment: .leading, spacing: 10) {
      Text("Components List")
        .font(.title2)
      VStack(alignment: .leading, spacing: 10) {
        ForEach(models2, id: \.id) { blueprint in
          VStack(alignment: .leading, spacing: 10) {
            HStack {
              Text("\(blueprint.typeModel.name)")
                .font(.title3)
              Spacer()
              Text("\(blueprint.quantity)")
                .font(.title3)
            }
            Divider()
            //Spacer()
            //Text("\(blueprint.)")
            ForEach(blueprint.materials, id: \.id) { material in
              HStack(alignment: .top) {
                Text(material.typeModel.name)
                Spacer()
                Text("\(material.quantityType.quantity * blueprint.quantity)")
              }
            }.padding(.leading, 15)
          }
        }.padding(.bottom, 10)
        
        //.padding([.top, .bottom], 5)
        //.border(.blue)
      }
      Spacer()
    }.frame(maxWidth: 250)
      .padding(.trailing)
  }
  
  func someList(_ data: BlueprintComponentListData) -> some View {
    return VStack {
      ForEach(data.items, id: \.id) { item in
        Text(item.typeModel.name + " \(item.quantityType.quantity)")
      }
    }
  }
  
  func groupInfo(for groupID: Int64) -> some View {
    let group = DataManager.shared.dbManager!.getGroup(for: groupID)//!.name
    return HStack {
      if let group = group {
        Text("\(group.name) - \(group.groupId)")
      }
    }
  }
}


// TODO: Move
extension BlueprintComponentView {
  func getBlueprint(for typeId: Int64) -> BlueprintModel? {
    let db = DataManager.shared.dbManager!.database
    
    guard let sql = db as? SQLDatabase else {
      return nil
    }
    let queryString =
      """
        select b.*, value from blueprintModel b,
        json_each(b.activities_manufacturing_products)
        where json_extract(value, '$.typeId') = \("\(typeId)")
      OR (
              select b.*, value from blueprintModel b,
              json_each(b.activities_reaction_products)
              where json_extract(value, '$.typeId') = \("\(typeId)")
      )
      """
    
    return try? sql.raw(SQLQueryString(queryString))
      .first(decoding: BlueprintModel.self)
      .wait()
  }
  
  func getComponents(for blueprint: BlueprintModel) {
    let materials = blueprint.activities.manufacturing.materials
    let db = DataManager.shared.dbManager!.database
    
    guard let sql = db as? SQLDatabase else {
      return
    }
    // while an items blueprint has manufacturing inputs
    // while a specific input is in a certain group?
    
//    let models2 = materials.compactMap { firstValue -> [ItemComponentDataDisplayable]? in
//      let typeMaterials: [TypeMaterialsModel] = DataManager.shared.dbManager!.getTypeMaterialModels(for: [firstValue.quantityType.typeId])
//
//      let foo = typeMaterials.compactMap { value -> ItemComponentDataDisplayable? in
//        let bar = value.materialData.compactMap { value -> BlueprintComponentDataDisplayable? in
//          guard let typeModel = try? TypeModel.query(on: DataManager.shared.dbManager!.database)
//            .filter(\.$typeId == value.materialTypeID)
//            .first()
//            .wait()
//          else {
//            return nil
//          }
//          return BlueprintComponentDataDisplayable(typeModel: typeModel, quantityTypeModel: value)
//        }
//
//        return ItemComponentDataDisplayable(data: firstValue, materials: bar)
//      }
//      return foo
//    }.flatMap { $0 }
  }
  
  func getJobs(for blueprint: BlueprintModel) {
    let db = DataManager.shared.dbManager!.database
    guard let sql = db as? SQLDatabase else {
      return
    }
    /*
     SELECT * FROM @table
     WHERE 'Joe' IN ( SELECT value FROM OPENJSON(Col,'$.names'))
     
     select b.*,
     value from blueprintModel b,
     json_each(b.activities_manufacturing_products) where json_extract(value, '$.typeId') = 41483
     
     SELECT * FROM blueprintModel
     WHERE json_extract(activities_manufacturing_products, '$.typeId') = 15;
     */

    // the materials needed to create the blueprint
    let bpMaterials = blueprint.activities.manufacturing.materials.map { $0 }
    
    let materialJobInfo = bpMaterials.compactMap { material -> MaterialManufacturingInfo? in
      // the specific material
      guard let blueprintModel = getBlueprint(for: material.typeId) else { return nil }
      
      getInputBlueprints(for: material)
      
      
      return MaterialManufacturingInfo(quantityTypeModel: material, blueprintModel: blueprintModel)
    }
    
    print("got \(materialJobInfo.count) blueprints")
    
    materialJobInfo.forEach { process(data: $0)}
  }
  
  func process(data: MaterialManufacturingInfo) {
    let blueprintModel = data.blueprintModel
    let quantityTypeModel = data.quantityTypeModel
    
    let count = quantityTypeModel.quantity
    
    guard let productsPerRun = blueprintModel.activities.manufacturing.products
      .first(where: {$0.typeId == quantityTypeModel.typeId})?.quantity
    else {
      print("WARN - no products per run for \(quantityTypeModel.typeId)")
      return
    }
    
    let requiredRuns = Int(ceil(Double(count) / Double(productsPerRun)))
    
//    print("count \(count) productsPerRun \(productsPerRun) requiredRuns \(requiredRuns)")
    
    
    
  }
  
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

#Preview {
  BlueprintComponentView(
    blueprintModel: BlueprintModel(
      data: BlueprintData(
        activities:
          BlueprintActivityData(
            copying: nil,
            manufacturing: nil,
            reaction: nil,
            research_material: nil,
            research_time: nil
          ),
        blueprintTypeID: 0,
        maxProductionLimit: 0))
  )
}

struct BlueprintComponentListData: Identifiable {
  var id: Int
  var groupName: String
  var items: [BlueprintComponentDataDisplayable]
  
  init(group: GroupModel, items: [BlueprintComponentDataDisplayable]) {
    self.id = Int(group.groupId)
    self.groupName = group.name
    self.items = items
  }
}

// object that combines QuantityTypeModel and BlueprintModel

struct MaterialManufacturingInfo {
  let quantityTypeModel: QuantityTypeModel
  let blueprintModel: BlueprintModel
  
  init(quantityTypeModel: QuantityTypeModel, blueprintModel: BlueprintModel) {
    self.quantityTypeModel = quantityTypeModel
    self.blueprintModel = blueprintModel
  }
}
