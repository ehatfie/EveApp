//
//  CharacterIndustryJobRow.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/16/24.
//

import SwiftUI

struct CharacterIndustryJobRow: View {
    let industryJobDisplayable: IndustryJobDisplayable
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(industryJobDisplayable.blueprintName)
                    if let productName = industryJobDisplayable.productName {
                        Text(productName)
                    }
                    //Spacer()
                }
            }//.frame(maxWidth: .infinity)
            Spacer()
        }
       
    }
}

#Preview {
    CharacterIndustryJobRow(
        industryJobDisplayable: IndustryJobDisplayable(
            industryJobModel: .init(),
            blueprintName: "",
            blueprintLocationName: "",
            productName: nil
        )
    )
}
