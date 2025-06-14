//
//  DisplayableStringPicker.swift
//  EveApp
//
//  Created by Erik Hatfield on 4/10/25.
//

import SwiftUI

struct DisplayableStringPicker: View {
    @Binding var selectedStrings: Set<DisplayableString>
    var possibleStrings: [DisplayableString]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Displayable String picker title")
            HStack(alignment: .top, spacing: 10) {
                List(possibleStrings, id: \.self, selection: $selectedStrings) { value in
                    Text(value.value)
                        .id(value.id)
                        .background(selectedStrings.contains(value) ? .yellow : Color.clear)
                }.listStyle(.bordered)
                
                Text("\(selectedStrings.count) selected")
            }
        }
    }
}

#Preview {
    DisplayableStringPicker(
        selectedStrings: .constant([]),
        possibleStrings: []
    )
}
