//
//  IPProductPickerView.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/21/24.
//

import SwiftUI

protocol TestHandler1 {
    func handler(name: String, runs: Int, me: Int) -> Void
}

struct IPProductPickerView: View {
    @State var numRuns: Int = 1
    @State var materialEfficiency: Int = 10
    
    @State var runsString: String = "1"
    @State var meString: String = "10"
    @State var product: String = "Curse Blueprint"
    
    @State var selectedValues: Set<Int64> = []
    
    @Binding var listData: [IPPlanPickerEntry]
    let handler: (String, Int, Int) -> Void
    
    let hh: PickerHandlerProtocol?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    TextField(
                        text: $product,
                        label: { Text("Product") }
                    ).frame(width: 150)
                    
                    HStack(spacing: 5) {
                        NumPicker(
                            title: "Runs",
                            pickerValue: $numRuns
                        ).frame(width: 75)
                        
                        NumPicker(
                            title: "ME",
                            pickerValue: $materialEfficiency
                        ).frame(width: 50)
                    }
                }
                
                Button(action: {
                    hh?.addJob(
                        name: product,
                        runs: numRuns,
                        materialEfficiency: materialEfficiency
                    )
                    product = ""
                    numRuns = 0
                    materialEfficiency = 0
                }, label: {
                    Text("Enter")
                })
            }.padding(.horizontal)
            
            VStack(alignment: .leading) {
                ForEach(listData, id: \.id) { item in
                    IPProductPickerRow(data: item) {
                        hh?.removeJob(item)
                    }
                }
            }
        }
    }
}

struct IPProductPickerRow: View {
    var data: IPPlanPickerEntry
    
    var callback: () -> Void
    
    var body: some View {
        HStack {
            Text(data.blueprintName)
            Text("Runs: \(data.runs)")
            Text("ME: \(data.materialEfficiency)")
            Button(action: callback) {
                Image(systemName: "xmark")
            }
        }
    }
}

#Preview {
    IPProductPickerView(
        listData: .constant([]),
        handler: { _,_,_  in },
        hh: nil
    )
}
