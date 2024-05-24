//
//  IndustryHelperView.swift
//  EveApp
//
//  Created by Erik Hatfield on 12/17/23.
//

import SwiftUI
import FluentKit

enum Race: Int64, CaseIterable, Identifiable {
  var id: Int64 { rawValue }
  
  case none = 0
  case amarr = 4
  case caldari = 1
  case gallente = 8
  case minmitar = 2
  
  var name: String  {
    switch self {
    case .amarr: "Amarr"
    case .caldari: "Caldari"
    case .gallente: "Gallente"
    case .minmitar: "Minmitar"
    case .none: ""
    }
  }
}

struct IndustryHelperView: View {
  @EnvironmentObject var db: DBManager
  
  @State var selectedRace: Race = .none
  
  
  init() {

  }
  
  var body: some View {
    
    VStack(alignment: .leading) {
      Text("Selected race \(selectedRace.name)")
      HStack {
        RacePickerView(selectedRace: $selectedRace)
        Spacer()
      }
      
      if selectedRace != .none {
        infoView()
      }
      
      Spacer()
    }.onAppear {
      let raceIds = Race.allCases.map { $0.rawValue }
      print("IndustryHelperView - dbManager \(db)")
      let foo = try! RaceModel.query(on: db.database)
        .filter(\.$raceID ~~ raceIds )
        .all()
        .wait()
      
      print("got \(foo.count) races")
    }.padding()
    .border(.red)
  }
  
  func infoView() -> some View {
    
    let typesForGroup = try! TypeModel.query(on: db.database)
      .join(GroupModel.self, on: \TypeModel.$groupID == \GroupModel.$groupId)
      .filter(GroupModel.self, \.$categoryID == Int64(6))
      .filter(TypeModel.self, \.$raceID == Int(selectedRace.id))
      .filter(TypeModel.self, \.$metaGroupID == 2)
      .filter(TypeModel.self, \.$published == true)
      .sort(TypeModel.self, \.$groupID)
      .join(TypeMaterialsModel.self, on: \TypeMaterialsModel.$typeID == \TypeModel.$typeId)
      .all()
      .wait()
    
    
    return VStack {
      List(typesForGroup, id: \.id) { item in
        VStack(alignment: .leading) {
          Text(item.name)
            .font(.title)

          if let type = try? item.joined(TypeMaterialsModel.self) {
           infoRow(type)
          }
        }
      }
    }
    
    func infoRow(_ type: TypeMaterialsModel) -> some View {
      let foo = try! type.materialData
        .map { value in
          return TypeModel.query(on: db.database).filter(\.$typeId == value.materialTypeID).all()
        }
        .flatten(on: db.database.eventLoop)
        .wait()
      
      let bar = try! type.materialData.map { materialData -> EventLoopFuture<(TypeModel?, MaterialDataModel)> in
        let future = TypeModel.query(on: db.database)
          .filter(\.$typeId == materialData.materialTypeID)
          .first()
          .and(value: materialData)
        
        return future
      }.flatten(on: db.database.eventLoop)
        .wait()
        .compactMap { $0 }
      
     /*
      
      Ingredient.query(on: req.db)
              .filter(\.$parent.$id == nil)
              .sort(\.$name)
              .all()
              .flatMap { ingredients in
                  ingredients.map { ingredient -> EventLoopFuture<APIIngredient>
                      let future = ingredient.$children.query(on: req.db).all().map { children in
                          APIIngredient(ingredient: ingredient, children: children)
                      }
                  }.flatten(on: req.eventLoop)
      */
      
      
      return VStack(alignment: .leading) {
        HStack {
          ForEach(bar, id: \.1.materialTypeID) { type, data in
            VStack {
              if let name = type?.name {
                Text(name)
                Text("\(data.quantity)")
              } else {
                Text("\(data.materialTypeID)")
                Text("\(data.quantity)")
              }
              
            }
          }
        }
      }
    }
  }
}

#Preview {
  IndustryHelperView()
}


struct RacePickerView: View {
  @Binding var selectedRace: Race
  
  var body: some View {
    Picker(selection: $selectedRace, content: {
      ForEach(Race.allCases, id: \.id) { item in
        Text("\(item.name)")
          .tag(item)
        
      }
    }, label: {
      Text("Pick Me")
    }).frame(maxWidth: 200)
  }
}

final class BlueprintInfoType: ModelAlias {
  static let name = "blueprint_info_type"
  let model = TypeModel()
}
