//
//  IndustryInfoView.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/24/23.
//

import SwiftUI

class IndustryInfoViewModel: ObservableObject {
    // character
    // get info for character
}

struct IndustryInfoView: View {
    @StateObject private var viewModel: IndustryInfoViewModel = IndustryInfoViewModel()
    //@Observable var viewModel: IndustryInfoViewModel
    
    var body: some View {
        VStack {
            industryView()
        }
        
    }
    
    func industryView() -> some View {
        return VStack {
            
        }
    }
}

#Preview {
    IndustryInfoView()
}


/**
List of jobs
etc
 
 */
