//
//  Untitled.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/21/24.
//

import SwiftUI

struct NumPicker: View {
    let title: String
    @Binding var pickerValue: Int
    @State var pickerText: String = ""
    
    var body: some View {
        Stepper(
          label: {
              TextField(
                title,
                text: $pickerText
              )
          },
          onIncrement: {
              pickerValue += 1
              pickerText = String(pickerValue)
          },
          onDecrement: {
              guard pickerValue > 0 else { return }
              
              pickerValue -= 1
              
              if pickerValue == 0 {
                  pickerText = ""
              } else {
                  pickerText = String(pickerValue)
              }
          },
          onEditingChanged: { _ in
            
          })
    }
}
