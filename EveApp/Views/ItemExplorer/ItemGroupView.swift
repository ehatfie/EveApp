//
//  ItemTypesView.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/19/23.
//

import SwiftUI
import Combine
import Fluent
import TestPackage1

class ItemGroupViewModel: ObservableObject {
  let itemGroup: GroupModel
  
  @Published var itemTypes: [ItemType]
  
  var types: [TypeModel] = []
  
  var cancellable: AnyCancellable? = nil
  
  init(itemGroup: GroupModel) {
    print("ItemGroupViewModel init \(itemGroup.groupId)")
    self.itemGroup = itemGroup
    self.itemTypes = []
    
    //loadTypes()
//    let dbManager = DataManager.shared.dbManager
//    
//    cancellable = dbManager?
//      .$dbLoaded
//      .sink(receiveValue: { value in
//        if value == true {
//          print("")
//          self.loadTypesData()
//        }
//      })
  }
  
  func loadTypesData() {
    print("loadTypesData()")
    let dbManager = DataManager.shared.dbManager
    
    let types = try! TypeModel.query(on: dbManager!.database)
      .filter(\.$groupID == itemGroup.groupId)
      .all()
      .wait()
    
    self.types = types
  }
  
  func loadTypes() {
    print("loadTypes()")
    //DataManager.shared.loadTypeData()
    //        guard let itemGroupInfo = itemGroup.groupInfoResponseData else {
    //            DataManager.shared.fetchGroupInfoFor(groupId: itemGroup.groupId)
    //            return
    //        }
  }
}

struct ItemGroupView: View {
  @ObservedObject var viewModel: ItemGroupViewModel
  
  var body: some View {
    NavigationView {
      VStack {
        List {
          ForEach(viewModel.types, id: \.id) { type in
            NavigationLink(destination: {
              ItemTypeDetailView(typeModel: type)
            }, label: {
              Text(type.name)
            })
          }
        }
        
      }
    }.onAppear {
      self.viewModel.loadTypes()
    }
  }
}

struct ItemTypesView_Previews: PreviewProvider {
  static var previews: some View {
    ItemGroupView(
      viewModel: ItemGroupViewModel(
        itemGroup: GroupModel()
      )
    )
  }
}
