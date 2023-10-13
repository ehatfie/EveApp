//
//  DogmaEffectView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/12/23.
//

import SwiftUI

struct DogmaEffectView: View {
    @Binding var dogmaEffect: DogmaEffectModel
    
    var body: some View {
        VStack {
            Text(dogmaEffect.effectName)
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
