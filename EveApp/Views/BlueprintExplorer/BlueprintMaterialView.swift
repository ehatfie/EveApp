//
//  BlueprintMaterialView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/28/23.
//

import SwiftUI
import Combine

struct BlueprintMaterialView: View {
    @Binding var blueprintMaterials: BlueprintManufacturingModel
    
    var cancellable: AnyCancellable? = nil
    
    init(blueprintMaterials: Binding<BlueprintManufacturingModel>) {
        self._blueprintMaterials = blueprintMaterials
        
    }
    var body: some View {
        MaterialDetailView(title: "blueprint", materials: blueprintMaterials.materials)
    }
}

//#Preview {
    //BlueprintMaterialView()
//}
