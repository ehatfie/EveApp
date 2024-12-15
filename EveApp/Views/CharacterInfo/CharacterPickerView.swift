//
//  CharacterPickerView.swift
//  EveApp
//
//  Created by Erik Hatfield on 12/14/24.
//

import SwiftUI

struct IdentifiedStringPickerView: View {
    @State var selectedIdentifier: IdentifiedString
    var options: [IdentifiedString] = [
      IdentifiedString(id: 0, value: "Test String"),
      IdentifiedString(id: 1, value: "Test String1"),
      IdentifiedString(id: 2, value: "Test String2"),
      IdentifiedString(id: 3, value: "Test String3"),
    ]
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
           
            Picker(
               selection: $selectedIdentifier,
               content: {
                  ForEach(options) { option in
                     Text(option.value)
                        .tag(option.id)
                  }
               },
               label: {
                  Text("text label \(selectedIdentifier.value)")
               }
            )
        }.padding()
        
    }
}

#Preview {
    IdentifiedStringPickerView(
        selectedIdentifier: IdentifiedString(id: 0, value: "Test String")
    )
}
