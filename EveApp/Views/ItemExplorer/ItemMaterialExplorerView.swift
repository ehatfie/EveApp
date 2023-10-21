//
//  ItemMaterialExplorerView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/20/23.
//

import SwiftUI
import Fluent

class ItemMaterialExplorerViewModel: ObservableObject {
    @Published var data: [TypeMaterialsModel] = []
    
    init() {
        
    }
    
    func getData() {
        let dbManager = DataManager.shared.dbManager
        
        let results = try! TypeMaterialsModel.query(on: dbManager!.database)
            .all()
            .wait()
        
        self.data = results
    }
}

struct ItemMaterialExplorerView: View {
    @ObservedObject var viewModel: ItemMaterialExplorerViewModel
    var body: some View {
        List($viewModel.data, id: \.id) { typeMaterialsModel in
            ItemMaterialDetailView(viewModel: ItemMaterialDetailViewModel(item: typeMaterialsModel.wrappedValue))
        }.onAppear {
            viewModel.getData()
        }
    }
}

#Preview {
    ItemMaterialExplorerView(viewModel: ItemMaterialExplorerViewModel())
}
