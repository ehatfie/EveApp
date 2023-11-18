//
//  BlueprintExplorer.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/25/23.
//

import SwiftUI
import Fluent

class BlueprintExplorerViewModel: ObservableObject {
  @Published var searchText: String = "legion"
  @Published var searchResults: [TypeModel] = []
  @Published var selectedBlueprint: BlueprintModel?
  
  func search() {
    print("searching \(searchText)")
    
    /*
     .join(TypeMaterialsModel.self, on: \TypeModel.$typeId == \TypeMaterialsModel.$typeID)
     .first().wait()
     */
    
    let results = (
      try? TypeModel
      .query(on: DataManager.shared.dbManager!.database)
      .join(
        BlueprintModel.self,
        on: \TypeModel.$typeId == \BlueprintModel.$blueprintTypeID
      )
      .filter(\.$name ~~ searchText)
      .filter(\.$published == true)
      .all()
      .wait()
    ) ?? []
   
    self.searchResults = results
     
    // 30002
  }
  
  func setSelectedBlueprint(to typeModel: TypeModel) {
    
    let result = try? BlueprintModel.query(on: DataManager.shared.dbManager!.database)
      .filter(\.$blueprintTypeID == typeModel.typeId)
      .first()
      .wait()
    
    self.selectedBlueprint = result
  }
}

struct BlueprintExplorerView: View {
  @State var items: [BlueprintModel] = []
  
  @ObservedObject var viewModel = BlueprintExplorerViewModel()
  
  init() {
    
  }
  
  func loadData() {
    print("BlueprintExplorerView-loadData()")
    //    let db = DataManager.shared.dbManager?.database
    //    items = try! BlueprintModel.query(on: db!)
    //      .all()
    //      .wait()
    //    print("done, got \(items.count)")
  }
  
  var body: some View {
    HStack(alignment: .top) {
      searchColumn()
        .frame(width: 300)
      Spacer()
        .frame(width: 10)
      if let selectedBlueprint = viewModel.selectedBlueprint {
        blueprintInfo(for: selectedBlueprint)
          .border(.red)
        BlueprintComponentView(blueprintModel: selectedBlueprint)
          .border(.blue)
      } else {
        
      }
      
      Spacer()
    }
    
  }
  
  func searchColumn() -> some View {
    VStack(alignment: .leading) {
      searchBar()
      searchResults()
    }
    .padding(.leading, 10)
  }
  
  func searchBar() -> some View {
    HStack(alignment: .top) {
      Text("Search: ")
      TextField(
        "title",
        text: $viewModel.searchText,
        prompt: Text("legion")
      ).frame(maxWidth: 350)
      
      Button(action: {
        viewModel.search()
      }, label: {
        Text("Submit")
      })
    }
  }
  
  func searchResults() -> some View {
    List(viewModel.searchResults, id: \.typeId) { result in
      Text("\(result.name)")
        .onTapGesture {
          print("typeId \(result.typeId)")
          self.viewModel.setSelectedBlueprint(to: result)
        }
        .padding(.vertical, 10)
    }
  }
  
  func blueprintInfo(for blueprint: BlueprintModel) -> some View {
    return BlueprintDetailView(blueprint: blueprint)
//    VStack {
//      HStack {
//        Text("Plueprint Info")
//        Spacer()
//      }
//    }
  }
}

#Preview {
  BlueprintExplorerView()
}
