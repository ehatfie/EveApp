//
//  IndustryHelperView.swift
//  EveApp
//
//  Created by Erik Hatfield on 12/17/23.
//

import SwiftUI
import FluentKit

enum Race: Int64, CaseIterable {
    case amarr = 4
    case caldari = 1
    case gallente = 8
    case minmitar = 2
}

struct IndustryHelperView: View {
    @EnvironmentObject var db: DBManager
    
    @State var selectedRace: Race?
    
    var body: some View {
        
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            Picker(selection: $selectedRace, content: {
              List(Race.allCases) { item in
                TypeModel.query(on: db.database).filter(\.$typeId)
                Text(item.rawValue)
              }
            }, label: <#T##() -> View#>)
        }
    }
}

#Preview {
    IndustryHelperView()
}
