//
//  ItemCategoryRow.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/10/23.
//

import SwiftUI

struct ItemCategoryRow: View {
    @State var category: ItemCategory
    
    @State var isExpanded: Bool = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                if let categoryInfo = category.categoryInfoResponseData {
                    Text("\(categoryInfo.name)")
                    Text("\(categoryInfo.groups.count) groups")
                } else {
                    Text("category: \(category.categoryId)")
                }
            }
            .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 500)
            .border(.red)
            .onTapGesture {
                guard let categoryInfo = category.categoryInfoResponseData else {
                    print("fetching info for \(category.categoryId)")
                    DataManager.shared.fetchCategoryInfoFor(categoryID: category.categoryId)
                    return
                }
                isExpanded = !isExpanded
                
                print("tapped on \(category)")
            }
            
            if isExpanded {
               CategoryGroupsView(viewModel: CategoryGroupsViewModel(category: category))
                .frame(maxWidth: .infinity, maxHeight: 250)
                .padding(.bottom, 10)
                .border(.blue)
            }
        }
        
    }
}

struct ItemCategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        ItemCategoryRow(
            category: ItemCategory(
                categoryId: 0,
                categoryInfoResponseData:
                    CategoryInfoResponseData(
                        category_id: 0,
                        groups: [0, 1, 2],
                        name: "Name",
                        published: true
                    )
            )
        )
    }
}
