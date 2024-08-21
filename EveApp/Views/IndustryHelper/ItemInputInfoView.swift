//
//  ItemInputInfoView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/2/24.
//

import SwiftUI
import FluentKit
import TestPackage1

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
        
        return returnModels.sorted(by: {$0.materialTypeId < $1.materialTypeId})
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
      //Grid {
        AnyLayout(
          FlowLayout(spacing: 8)
        ) {
          ForEach($viewModel.inputInfos, id: \.materialTypeId) { inputInfo in
            //GridRow {
            VStack(alignment: .leading) {
                Text(inputInfo.wrappedValue.typeModel.name)
                .font(.system(.subheadline))
                Text("\(inputInfo.wrappedValue.quantity)")
              }
            }
          //}
        }
      }
   // }
  }
}

#Preview {
  ItemInputInfoView(viewModel: ItemInputInfoViewModel(TypeMaterialsModel()))
}



struct FlowLayout: Layout {
  
  var spacing: CGFloat = 8
  
  func layout(
    sizes: [CGSize],
    spacing: CGFloat = 8,
    containerWidth: CGFloat
  ) -> (offsets: [CGPoint], size: CGSize) {
    var result: [CGPoint] = []
    var currentPosition: CGPoint = .zero
    var lineHeight: CGFloat = 0
    var maxX: CGFloat = 0
    for size in sizes {
      if currentPosition.x + size.width > containerWidth {
        currentPosition.x = 0
        currentPosition.y += lineHeight + spacing
        lineHeight = 0
      }
      result.append(currentPosition)
      currentPosition.x += size.width
      maxX = max(maxX, currentPosition.x)
      currentPosition.x += spacing
      lineHeight = max(lineHeight, size.height)
    }
    
    return (result,
            .init(width: maxX, height: currentPosition.y + lineHeight))
    
  }
  
  func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) -> CGSize {
    let containerWidth = proposal.width ?? .infinity
    let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
    
    return layout(sizes: sizes,
                  spacing: spacing,
                  containerWidth: containerWidth).size
  }
  
  func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout ()
  ) {
    let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
    let offsets = layout(
      sizes: sizes,
      spacing: spacing,
      containerWidth: bounds.width
    ).offsets
    
    for (offset, subview) in zip(offsets, subviews) {
      subview.place(at: .init(x: offset.x + bounds.minX,
                              y: offset.y + bounds.minY),
                    proposal: .unspecified
      )
    }
  }
}
