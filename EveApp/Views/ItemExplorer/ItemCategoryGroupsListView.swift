//
//  ItemCategoryListView.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/19/23.
//

import SwiftUI
import Combine
import Fluent

class ItemCategoryGroupsListViewModel: ObservableObject {
  let categoryModel: CategoryModel
    
  var groups: [GroupModel] = []
    
  var cancellable: AnyCancellable? = nil
    
  init(category: CategoryModel) {
    self.categoryModel = category
    print("ItemCategoryGroupListVewiModel init")
    let dbManager = DataManager.shared.dbManager
    
//    cancellable = dbManager?
//      .$dbLoaded
//      .sink(receiveValue: { value in
//        if value == true {
//          print("")
//          self.loadGroupsData()
//        }
//      })
  }
  
  func loadGroupsData() {
    let dbManager = DataManager.shared.dbManager
    let groups = try! GroupModel.query(on: dbManager!.database)
      .filter(\.$categoryID == self.categoryModel.categoryId)
      .all()
      .wait()
    print("got \(groups.count) for \(self.categoryModel.categoryId)")
    self.groups = groups
  }
    
  func loadGroups() {
    print("loadGroups()")
      
    //DataManager.shared.loadGroupData()

  }
}

struct ItemCategoryGroupsListView: View {
    @ObservedObject var viewModel: ItemCategoryGroupsListViewModel
  
    var body: some View {
        NavigationView {
            List {
              ForEach($viewModel.groups, id: \.id) { group in
                
                NavigationLink(destination: {
                  ItemGroupView(
                    viewModel: ItemGroupViewModel(itemGroup: group.wrappedValue)
                  )
                }, label: {
                  Text(group.name.wrappedValue)
//                  if let info = group.groupInfoResponseData {
//                    Text("\(info.name)")
//                  } else {
//                    Text("ID: \(group.groupId)")
//                  }
                  
                })
              }
//                ForEach(viewModel.groups, id: \.id) { group in
//                    NavigationLink(destination: {
//                        ItemGroupView(
//                            viewModel: ItemGroupViewModel(itemGroup: group)
//                        )
//                    }, label: {
//                        if let info = group.groupInfoResponseData {
//                            Text("\(info.name)")
//                        } else {
//                            Text("ID: \(group.groupId)")
//                        }
//                        
//                    })
//                }
            }
        }.onAppear {
            self.viewModel.loadGroups()
        }
    }
}

struct ItemCategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        ItemCategoryGroupsListView(
            viewModel: ItemCategoryGroupsListViewModel(
                category: CategoryModel()
            )
        )
    }
}
