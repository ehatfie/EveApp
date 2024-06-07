//
//  ItemInputInfoView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/2/24.
//

import SwiftUI
import FluentKit

class InputInfo: Identifiable {
  var id = UUID()
  let quantity: Int64
  let materialTypeId: Int64
  let typeModel: TypeModel
  
  init(quantity: Int64, materialTypeId: Int64, typeModel: TypeModel) {
    self.quantity = quantity
    self.materialTypeId = materialTypeId
    self.typeModel = typeModel
  }
}

@Observable class ItemInputInfoViewModel {
  var loading: Bool = false
  let model: TypeMaterialsModel
  var inputInfos: [InputInfo] = []
  
  init(_ model: TypeMaterialsModel) {
    self.model = model
    load()
  }
  
  func load() {
    loading = true
    Task {
      let db = await DataManager.shared.dbManager!
      
      let results = await withTaskGroup(
        of: InputInfo?.self,
        returning: [InputInfo].self
      ) { taskGroup in
        var returnModels = [InputInfo]()
        model.materialData.forEach { value in
          taskGroup.addTask {
            do {
              guard let typeModel = try await db.getInputObjects(for: value.materialTypeID) else { return nil }
              return InputInfo(
                quantity: value.quantity,
                materialTypeId: value.materialTypeID,
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
      
      inputInfos = results
      self.loading = false
    }
  }
}

struct ItemInputInfoView: View {
  @Bindable var viewModel: ItemInputInfoViewModel
  var body: some View {
    VStack(alignment: .leading) {
      Grid {
        HStack {
          ForEach($viewModel.inputInfos, id: \.materialTypeId) { inputInfo in
            GridRow {
              Text(inputInfo.wrappedValue.typeModel.name)
              Text("\(inputInfo.wrappedValue.quantity)")
            }
          }
        }
      }

    }
  }
}

#Preview {
  ItemInputInfoView(viewModel: ItemInputInfoViewModel(TypeMaterialsModel()))
}
