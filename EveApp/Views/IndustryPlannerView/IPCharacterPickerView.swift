//
//  IPCharacterPickerView.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/23/24.
//

import SwiftUI

struct IPCharacterPickerView: View {
    @Binding var selectedCharacters: Set<IdentifiedString>
    var possibleCharacters: [IdentifiedString]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Character inputs")
            HStack(alignment: .top, spacing: 10) {
                List(possibleCharacters, id: \.self, selection: $selectedCharacters) { characterName in
                    Text(characterName.value)
                        .id(characterName)
                }.listStyle(.bordered)
                
                Text("\(selectedCharacters.count) selected")
            }
        }
    }
}

#Preview {
    IPCharacterPickerView(
        selectedCharacters: .constant([]),
        possibleCharacters: []
    )
}
