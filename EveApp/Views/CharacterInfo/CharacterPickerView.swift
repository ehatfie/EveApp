//
//  CharacterPickerView.swift
//  EveApp
//
//  Created by Erik Hatfield on 12/14/24.
//

import SwiftUI

struct IdentifiedStringPickerView: View {
    @Binding var selectedIdentifier: IdentifiedString
    var options: [IdentifiedString]
    
    var body: some View {
        VStack {
            Picker(
               selection: $selectedIdentifier,
               content: {
                  ForEach(options) { option in
                     Text(option.value)
                        .tag(option)
                  }
               },
               label: {
                  Text("Selected Character")
               }
            )
        }.padding()
        
    }
}

#Preview {
    IdentifiedStringPickerView(
      selectedIdentifier: .constant(IdentifiedString(id: 0, value: "Test String")),
      options: []
    )
}
