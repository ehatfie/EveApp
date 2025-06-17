//
//  SearchRootView.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/14/25.
//

import SwiftUI
import ModelLibrary

enum SearchType: String, CaseIterable {
    case station
    case player
}

@Observable class SearchRootViewModel {
    var searchText: String = ""
    var selectedSearchType: SearchType = .station
    var stationResponse: GetStructureInfoResponse? = nil
    
    func search() {
        Task {
            guard !searchText.isEmpty else { return }
            switch selectedSearchType {
            case .station:
                print("search for station")
                if let stationId = Int64(searchText),
                   let result = await DataManager.shared.fetchStructure(for: stationId) {
                    print("++ got search result \(result)")
                    stationResponse = result
                } else {
                    print("++ no search result")
                    stationResponse = nil
                }
                
            case .player:
                print("search for player")
            }
        }
    }
}


struct SearchRootView: View {
    @State var viewModel: SearchRootViewModel = SearchRootViewModel()
    
    var body: some View {
        VStack {
            Text("Search Root View")
            searchTypePicker()
            HStack {
                TextField("Search", text: $viewModel.searchText)
                Button("Search") {
                    viewModel.search()
                }
            }.padding()
            Spacer()
        }.padding()
    }
    
    func searchTypePicker() -> some View {
        HStack {
            ForEach(SearchType.allCases, id: \.self) { searchType in
                Button(action: {
                    viewModel.selectedSearchType = searchType
                }) {
                    Text(searchType.rawValue)
                        .foregroundColor(viewModel.selectedSearchType == searchType ? .blue : .primary)
                        .padding(8)
                        .background(viewModel.selectedSearchType == searchType ? Color.gray.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                }
            }
        }
    }
}

#Preview {
    SearchRootView()
}
