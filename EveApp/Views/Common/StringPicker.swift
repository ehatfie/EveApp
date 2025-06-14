//
//  StringPicker.swift
//  EveApp
//
//  Created by Erik Hatfield on 4/10/25.
//

import SwiftUI

struct StringPicker: View {
    @Binding var selectedStrings: Set<String>
    var possibleStrings: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("String picker title")
            HStack(alignment: .top, spacing: 10) {
                List(possibleStrings, id: \.self, selection: $selectedStrings) { value in
                    Text(value)
                        .id(value)
                        .background(selectedStrings.contains(value) ? .yellow : Color.clear)
                }.listStyle(.bordered)
                
                Text("\(selectedStrings.count) selected")
            }
        }
    }
}

#Preview {
    StringPicker(
        selectedStrings: .constant([]),
        possibleStrings: []
    )
}
