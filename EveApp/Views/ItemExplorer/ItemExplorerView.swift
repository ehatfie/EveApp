//
//  ItemExplorerView.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/5/23.
//

import SwiftUI
import Combine
import ModelLibrary

class ItemCategoryID: Identifiable {
  var id: Int32
  
  init(id: Int32) {
    self.id = id
  }
}

class ItemExplorerViewModel: ObservableObject {
  var categoryIDs: [Int32] = []
  @Published var categories: [CategoryModel]
  
  @Published var selectedCategory: CategoryModel?
  @Published var selectedGroup: GroupModel?
  @Published var selectedType: TypeModel?
  
  var cancellable: AnyCancellable? = nil
  
  init() {
    categories = try! DataManager.shared
      .dbManager!
      .database
      .query(CategoryModel.self)
      .sort(\.$categoryId)
      .all()
      .wait()
  }
  
  func loadCategories() {
    
  }
  
  func fetchCategories() {
    //DataManager.shared.fetchCategories()
  }
}

struct ItemExplorerView: View {
  @ObservedObject var viewModel: ItemExplorerViewModel
  
  var body: some View {
    VStack {
      Text("ItemExplorerView")
      RadialLayout {
       ForEach(viewModel.categories, id: \.categoryId) { category in
          categoryRow(
            category: category,
            isSelected: viewModel.selectedCategory?.categoryId == category.categoryId
          )
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .onTapGesture {
            viewModel.selectedCategory = category
            viewModel.selectedGroup = nil
            viewModel.selectedType = nil
          }
        }.frame(maxWidth: 150)
        
        CategoryInfoView(
          selectedCategory: $viewModel.selectedCategory,
          selectedGroup: $viewModel.selectedGroup
        )
        .frame(maxWidth: 200)
        
        GroupInfoView(
          selectedGroup: $viewModel.selectedGroup,
          selectedType: $viewModel.selectedType
        ).frame(maxWidth: 100)
        
        TypeInfoView(selectedType: $viewModel.selectedType)
          .frame(maxWidth: 500)
        
        Spacer()
      }
    }
  }
  
  func categoryRow(category: CategoryModel, isSelected: Bool) -> some View {
    return HStack {
      Text(category.name)
      //Text("\(category.categoryId)")
    }.border(
      viewModel.selectedCategory?.categoryId == category.categoryId ? .red: .clear
    )
  }
}

struct ItemExplorerView_Previews: PreviewProvider {
  static var previews: some View {
    ItemExplorerView(viewModel: ItemExplorerViewModel())
  }
}

struct RadialLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        // accept the full proposed space, replacing any nil values with a sensible default
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        // calculate the radius of our bounds
        let radius = min(bounds.size.width, bounds.size.height) / 2

        // figure out the angle between each subview on our circle
        let angle = Angle.degrees(360 / Double(subviews.count)).radians

        for (index, subview) in subviews.enumerated() {
            // ask this view for its ideal size
            let viewSize = subview.sizeThatFits(.unspecified)

            // calculate the X and Y position so this view lies inside our circle's edge
            let xPos = cos(angle * Double(index) - .pi / 2) * (radius - viewSize.width / 2)
            let yPos = sin(angle * Double(index) - .pi / 2) * (radius - viewSize.height / 2)

            // position this view relative to our centre, using its natural size ("unspecified")
            let point = CGPoint(x: bounds.midX + xPos, y: bounds.midY + yPos)
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
    }
}

struct EqualWidthLayout: Layout {
  
  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
      // accept the full proposed space, replacing any nil values with a sensible default
    print("proposal \(proposal)")
    //let maxSize = maxSize(subviews: subviews)
    let maxWidth = min(maxWidth(subviews: subviews), proposal.width ?? .infinity)
    let maxHeight = maxHeight(subviews: subviews, maxWidth: maxWidth)
    let maxSize = CGSize(width: maxWidth, height: maxHeight)
    
    let spacing = spacing(subviews: subviews)
    let totalSpacing = spacing.reduce(0.0, +)
    
    print("max size \(maxSize)")
    return CGSize(
      width: maxWidth,
      height: maxSize.height * CGFloat(subviews.count) + totalSpacing
    )
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
    print("placeSubviews in \(bounds)")
    let padding = 8
    
    let maxWidth = min(maxWidth(subviews: subviews), (bounds.width - CGFloat(padding * 2)))
    let maxHeight = maxHeight(subviews: subviews, maxWidth: maxWidth)
    let maxSize = CGSize(width: maxWidth, height: maxHeight)
    
    //var maxSize = maxSize(subviews: subviews)
    let spacing = spacing(subviews: subviews)
    
    print("maxSize \(maxSize) spacing \(spacing)")
    
//    if maxSize.width > bounds.width {
//      print("replacing max size \(maxSize.width) with \(bounds.width)")
//      maxSize = CGSize(width: bounds.width, height: maxSize.height)
//    }
    
    let sizeProposal = ProposedViewSize(width: maxSize.width,
                                        height: maxSize.height)
    print("sizeProposal \(sizeProposal)")
    
    var x = bounds.midX - maxSize.width / 2
    var y = bounds.minY + maxSize.height / 2
    
    for index in subviews.indices {
      subviews[index].place(at: CGPoint(x: bounds.midX, y: y),
                            anchor: .center,
                            proposal: sizeProposal)
      //x += maxSize.width + spacing[index]
      y += maxSize.height + spacing[index]
    }
  }
  
  private func maxSize(subviews: Subviews) -> CGSize {
    let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }

    let maxSize: CGSize = subviewSizes.reduce(.zero, { result, size in
      CGSize(
        width: max(result.width, size.width),
        height: max(result.height, size.height))
    })

    return maxSize
  }
  
  private func maxWidth(subviews: Subviews) -> CGFloat {
    let subviewSizes = subviews.map { $0.sizeThatFits(.unspecified) }
    
    let maxWidth: CGFloat = subviewSizes.reduce(.zero, { result, size in
          max(result, size.width)
        }
    )
    return maxWidth
  }
  
  private func maxHeight(subviews: Subviews, maxWidth: CGFloat) -> CGFloat {
    let subviewSizes = subviews.map { $0.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))}
    
    
    let maxHeight: CGFloat = subviewSizes.reduce(.zero, { result, size in
          max(result, size.height)
        }
    )

      return maxHeight
    }
    
    private func spacing(subviews: Subviews) -> [CGFloat] {

        subviews.indices.map { index in

            guard index < subviews.count - 1 else { return 0.0 }

            return subviews[index].spacing.distance(to: subviews[index + 1].spacing,
                                                  along: .vertical)
        }
    }
}
