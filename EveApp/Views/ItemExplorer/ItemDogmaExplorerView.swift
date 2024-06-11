//
//  ItemDogmaExplorerView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/14/23.
//

import SwiftUI
import Fluent

struct ItemInfoDisplayable: Identifiable {
  let id: UUID = UUID()
  let typeDogmaInfoModel: TypeDogmaInfoModel
  let typeModel: TypeModel
}

@Observable class ItemDogmaExplorerViewModel {
  var data: [TypeDogmaInfoModel] = []
  var items: [ItemInfoDisplayable] = []
  
  init() {
    let dbManager = DataManager.shared.dbManager
  }
  
  func getData() {
    Task {
      let dbManager = await DataManager.shared.dbManager
      let models = try! await TypeDogmaInfoModel.query(on: dbManager!.database)
        .join(TypeModel.self, on: \TypeDogmaInfoModel.$typeId == \TypeModel.$typeId)
        .paginate(PageRequest(page: 1, per: 200))
        .get()
      
      print("ItemDogmaExplorerViewModel data count \(models.items.count)")
      self.data = models.items
      
      let results = await withTaskGroup(
        of: ItemInfoDisplayable?.self,
        returning: [ItemInfoDisplayable].self
      ) { taskGroup in
        var returnModels = [ItemInfoDisplayable]()
        models.items.forEach { value in
          taskGroup.addTask {
            do {
              let typeModel = try value.joined(TypeModel.self)
              return ItemInfoDisplayable(
                typeDogmaInfoModel: value,
                typeModel: typeModel
              )
            } catch let error {
              print("ItemInputInfoView - error \(error)")
              return nil
            }
          }
        }
        
        for await result in taskGroup {
          if let result = result {
            returnModels.append(result)
          }
          
        }
        
        return returnModels
      }
      
      self.items = results
    }
  }
}

struct ItemDogmaExplorerView: View {
  var viewModel: ItemDogmaExplorerViewModel
  
  var body: some View {
    VStack {
      List(viewModel.items, id: \.id) { item in
        HStack {
          Text("\(item.typeModel.name)")
          Text("attributes: \(item.typeDogmaInfoModel.attributes.count)")
          Text("effects: \(item.typeDogmaInfoModel.effects.count)")
        }
      }.onAppear{
        viewModel.getData()
      }
      
//      List(viewModel.data, id: \.id) { typeDogmaInfoModel in
//        HStack {
//          Text("\(typeDogmaInfoModel.typeId)")
//          Text("attributes: \(typeDogmaInfoModel.attributes.count)")
//          Text("effects: \(typeDogmaInfoModel.effects.count)")
//        }
//      }
    }
  }
}

#Preview {
  ItemDogmaExplorerView(viewModel: ItemDogmaExplorerViewModel())
}
