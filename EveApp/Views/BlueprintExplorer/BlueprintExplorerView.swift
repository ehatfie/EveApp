//
//  BlueprintExplorer.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/25/23.
//

import SwiftUI

struct BlueprintExplorerView: View {
  @State var items: [BlueprintModel] = []
  
  init() {
    
  }
  
  func loadData() {
    print("BlueprintExplorerView-loadData()")
    let db = DataManager.shared.dbManager?.database
    items = try! BlueprintModel.query(on: db!)
      .all()
      .wait()
    print("done, got \(items.count)")
  }
  
  var body: some View {
    List(items, id: \.id) { blueprint in
      BlueprintDetailView(blueprint: blueprint)
    }
    .onAppear {
      loadData()
    }
  }
}

#Preview {
  BlueprintExplorerView()
}
