//
//  ItemGroupView.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/10/23.
//

import SwiftUI
import Combine

class CategoryGroupsViewModel: ObservableObject {
    let itemCategory: ItemCategory // CategoryInfoResponseData?
    
    @Published var groups: [ItemGroup] = []
    
    var cancellable: AnyCancellable? = nil
    
    init(category: ItemCategory) {
        self.itemCategory = category
        
        loadGroups()
        
        self.cancellable = DataManager.shared
            .$groupInfoByID
            .receive(on: RunLoop.main)
            .sink(receiveValue: { groupInfoById in
                guard let groupIds = self.itemCategory.categoryInfoResponseData?.groups else {
                    print("no group ids")
                    return
                }
                
                self.groups = groupIds.map { groupId in
                    ItemGroup(
                        categoryId: groupInfoById[groupId]?.category_id,
                        groupId: groupId,
                        groupInfoResponseData: groupInfoById[groupId]
                    )
                }
            })
    }
    
    func loadGroups() {
        guard let groupIds = itemCategory.categoryInfoResponseData?.groups else {
            print("no group ids")
            return
        }
        let groupsById = UserDefaultsHelper.loadFromUserDefaults(
            type: [Int32: GroupInfoResponseData].self,
            key: .groupInfoByIdResponse
        )
        let itemGroups = groupIds.map { groupId in
            let groupInfoData = groupsById?[groupId]
            let itemGroup = ItemGroup(
                categoryId: groupInfoData?.category_id,
                groupId: groupId,
                groupInfoResponseData: groupInfoData
            )
            return itemGroup
        }
        
        self.groups = itemGroups
    }
    
    func fetchGroupInfo(for groupId: Int32) {
        DataManager.shared.fetchGroupInfoFor(groupId: groupId)
    }
}

struct CategoryGroupsView: View {
    @ObservedObject var viewModel: CategoryGroupsViewModel
    var body: some View {
        VStack {
            List(viewModel.groups, id: \.groupId) { group in
                HStack {
                    Text("groupId \(group.groupId)")
                    if let groupInfo = group.groupInfoResponseData {
                        Text(groupInfo.name)
                    }
                }
                .padding()
                .border(.green)
                .onTapGesture {
                    guard let groupInfo = group.groupInfoResponseData else {
                        print("fetching info for \(group.groupId)")
                        viewModel.fetchGroupInfo(for: group.groupId)
                        return
                    }
                    
                    print("tapped on \(group.groupId)")
                }
            }
            .frame(height: 250)
            .border(.orange)
        }
        
    }
}

struct CategoryGroupsView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryGroupsView(
            viewModel: CategoryGroupsViewModel(
                category: ItemCategory(categoryId: 0)
            )
        )
    }
}
