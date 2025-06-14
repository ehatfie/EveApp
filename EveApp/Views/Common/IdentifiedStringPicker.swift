//
//  IdentifiedStringPicker.swift
//  EveApp
//
//  Created by Erik Hatfield on 4/10/25.
//

import SwiftUI

struct IdentifiedStringPicker: View {
    @Binding var selectedStrings: Set<IdentifiedString>
    var possibleStrings: [IdentifiedString]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("String picker title")
            HStack(alignment: .top, spacing: 10) {
                List(possibleStrings, id: \.self, selection: $selectedStrings) { value in
                    Text(value.value)
                        .id(value)
                }.listStyle(.bordered)
                
                Text("\(selectedStrings.count) selected")
            }
        }
    }
}


#Preview {
    IdentifiedStringPicker(
        selectedStrings: .constant([]),
        possibleStrings: []
    )
}
