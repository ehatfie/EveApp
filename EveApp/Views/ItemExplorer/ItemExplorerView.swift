//
//  ItemExplorerView.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/5/23.
//

import SwiftUI
import Combine

class ItemCategoryID: Identifiable {
    var id: Int32
    
    init(id: Int32) {
        self.id = id
    }
}



class ItemExplorerViewModel: ObservableObject {
    var categoryIDs: [Int32] = []
    @Published var categories: [ItemCategory] = []
    
    var cancellable: AnyCancellable? = nil
    
    init() {
        loadCategories()
        
        cancellable = DataManager.shared
            .$categoryInfoByID
            .receive(on: RunLoop.main)
            .sink(receiveValue: { categoryInfoByID in
                self.categories = self.categoryIDs
                    .map {
                        ItemCategory(
                            categoryId: $0,
                            categoryInfoResponseData: categoryInfoByID[$0]
                        )
                    }
            })
        
    }
    
    func loadCategories() {
        guard let categoryDataResponse = UserDefaultsHelper.loadFromUserDefaults(type: [Int32].self, key: .categoryDataResponse) else {
            print("IE - no category data response")
            return
        }
        self.categoryIDs = categoryDataResponse
        let categoriesByID = UserDefaultsHelper.loadFromUserDefaults(type: [Int32: CategoryInfoResponseData].self, key: .categoriesByIdResponse)
        
        // map local data to object to use
        self.categories = categoryDataResponse.map({ categoryID in
            ItemCategory(categoryId: categoryID, categoryInfoResponseData: categoriesByID?[categoryID])
        })
    }
    
    func fetchCategories() {
        DataManager.shared.fetchCategories()
    }
}

struct ItemExplorerView: View {
    @ObservedObject var viewModel: ItemExplorerViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        VStack {
            List(viewModel.categories, id: \.categoryId) { category in
                ItemCategoryRow(category: category)
                    
            }
            Button("Fetch Categories", action: {
                self.viewModel.fetchCategories()
            })
        }
    }
}

struct ItemExplorerView_Previews: PreviewProvider {
    static var previews: some View {
        ItemExplorerView(viewModel: ItemExplorerViewModel())
    }
}
