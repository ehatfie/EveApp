//
//  DogmaEffectView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/12/23.
//

import SwiftUI
import TestPackage1

struct DogmaEffectView: View {
    @Binding var dogmaEffect: DogmaEffectModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(dogmaEffect.effectID)")
                Text(dogmaEffect.effectName)
            }
            
            Text(dogmaEffect.descriptionID ?? "")
            Text(dogmaEffect.displayNameID ?? "")
        }
        
        
    }
}

#Preview {
    DogmaEffectView(dogmaEffect: Binding(get: {
        DogmaEffectModel()
    }, set: { _ in 	}))
}
