//
//  RequestBuilderview.swift
//  EveApp
//
//  Created by Erik Hatfield on 4/4/25.
//

import SwiftUI
import ModelLibrary
import Fluent

/*
 /kills/
 /losses/
 /w-space/
 /solo/
 /finalblow-only/
 /awox/ Boolean, pass 0 or 1
 /npc/ Boolean, pass 0 or 1
 */

enum FetchTypeModifier: String, CaseIterable, Identifiable {
    case kills = "kills"
    case losses = "losses"
    case wSpace = "w-space"
    case solo = "solo"
    case finalBlowOnly = "finalblow-only"
    case awox = "awox"
    case npc = "npc"
    
    var id: String { self.rawValue }
}
/*
 
 Fetch modifiers

 /characterID/#/
 /corporationID/#/
 /allianceID/#/
 /factionID/#/
 /shipTypeID/#/
 /groupID/#/
 /systemID/#/
 /regionID/#/
 /warID/#/
 /iskValue/#/
 /killID/#/
 */

enum FetchModifier1 {
    case characterID(Int)
    case corporationID(Int)
    case allianceID(Int)
    case factionID(Int)
    case shipTypeID(Int)
    case groupID(Int)
    case systemID(Int)
    case regionID(Int)
    
    var value: String {
        switch self {
        case .characterID(let id): return "characterID/\(id)/"
        case .corporationID(let id): return "corporationID/\(id)/"
        case .allianceID(let id): return "allianceID/\(id)/"
        case .factionID(let id): return "factionID/\(id)/"
        case .shipTypeID(let id): return "shipTypeID/\(id)/"
        case .groupID(let id): return "groupID/\(id)/"
        case .systemID(let id): return "systemID/\(id)/"
        case .regionID(let id): return "regionID/\(id)/"
        }
    }
}

enum FetchModifier: Identifiable, CaseIterable {
    case characterID
    case corporationID
    case allianceID
    case factionID
    case shipTypeID
    case groupID
    case systemID
    case regionID
    
    var value: String {
        switch self {
        case .characterID: return "characterID"
        case .corporationID: return "corporationID"
        case .allianceID: return "allianceID"
        case .factionID: return "factionID"
        case .shipTypeID: return "shipTypeID"
        case .groupID: return "groupID"
        case .systemID: return "systemID"
        case .regionID: return "regionID"
        }
    }
    
    var id: String {
        self.value
    }
}

/*
 
 /page/#/
 /year/Y/ (requires month as well or will be ignored)
 /month/m/
 /pastSeconds/s/
 /killID/#/
 */

enum LimitModifier1 {
    case page(Int)
    case year(Int)
    case month(Int)
    case pastSeconds(Int)
    case killID(Int)
    
    var value: String {
        switch self {
        case .page(let page): return "page/\(page)/"
        case .year(let year): return "year/\(year)/"
        case .month(let month): return "month/\(month)/"
        case .pastSeconds(let seconds): return "pastSeconds/\(seconds)/"
        case .killID(let killID): return "killID/\(killID)/"
        }
    }
    
    var id: String {
        switch self {
        case .page: return "page"
        case .killID: return "killID"
        case .month: return "month"
        case .pastSeconds: return "pastSeconds"
        case .year: return "year"
        }
    }
}


enum LimitModifier: Identifiable, CaseIterable {
    case page
    case year
    case month
    case pastSeconds
    case killID
    
    var value: String {
        switch self {
        case .page: return "page"
        case .year: return "year"
        case .month: return "month"
        case .pastSeconds: return "pastSeconds"
        case .killID: return "killID"
        }
    }
    
    var id: String {
        self.value
    }
}

enum SearchTypes: String, CaseIterable, Identifiable {
    case characterName = "Character"
    case corporationName = "Corpooration"
    case allianceName = "Alliance"
    
    var id: String {
        self.rawValue
    }
}

@Observable class RequestBuilderViewModel {
    let baseURLString = "https://zkillboard.com/api/"
    var selectedModifier: FetchTypeModifier = .kills
    var selectedSearchType: SearchTypes? = nil
    var modifierText: String = ""
    
    var isVerifying: Bool = false
    var validSearchResult: Bool? = nil
    
    var characterNames: [IdentifiedString] = []
    var selectedModifierText: IdentifiedString?
    
    init() {
        getCharacterIdentifiers()
    }
    
    func search() {
        let searchText = modifierText
        print("searching for \(selectedSearchType?.rawValue ?? "none") \(searchText)")
        
        validSearchResult = nil
        Task {
            let dataManager = await DataManager.shared
            var result = await dataManager.verifyCharacter(characterName: searchText)
            if !result {
                isVerifying = true
                guard let searchResult = await dataManager.searchCharacter(named: searchText),
                      let characterResult = searchResult.character else {
                    print("no search result for \(searchText)")
                    return
                }
                let characterIds = characterResult.map { Int64($0) }
                await dataManager.loadCharacterInfo(for: characterIds)
            }
            
            result = await dataManager.verifyCharacter(characterName: searchText)
            
            validSearchResult = result
            isVerifying = false
            print("got result \(result)")
            //isVerifying = false
        }
        
    }
    
    func getCharacterIdentifiers() {
        Task {
            let dataManager = await DataManager.shared
            let dbManager = dataManager.dbManager!
            let models = await dbManager.getCharacterIdentifiersModels()
            let values = models.map { IdentifiedString(id: $0.characterID, value: $0.name)}
            characterNames = values
        }
    }
    
}

struct RequestBuilderView: View {
    @State var viewModel: RequestBuilderViewModel = RequestBuilderViewModel()
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            Text("URL: \(viewModel.baseURLString) \(viewModel.selectedModifier.rawValue)\(viewModel.selectedModifier.rawValue)\(viewModel.selectedModifierText?.value ?? "")")
            HStack(alignment: .top) {
                VStack {
                    Picker("Fetch Type", selection: $viewModel.selectedModifier) {
                        ForEach(FetchTypeModifier.allCases) { value in
                            Text(value.rawValue)
                                .tag(value)
                        }
                    }
                }
                
                VStack(spacing: 10) {
                    Picker("Fetch modifier", selection: $viewModel.selectedSearchType) {
                        ForEach(SearchTypes.allCases) { value in
                            Text(value.rawValue)
                                .tag(value)
                        }
                    }
                    if let selectedFetchModifier = viewModel.selectedSearchType {
                        VStack {
                            HStack {
                                TextField("Title", text: $viewModel.modifierText)
                                Button("Search") {
                                    viewModel.search()
                                }
                                if viewModel.isVerifying {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                }
                                if let validSearchResult = viewModel.validSearchResult {
                                    if validSearchResult {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.green)
                                    } else {
                                       Image(systemName: "xmark")
                                            .foregroundColor(.red)
                                    }
                                }
    
                            }
                            // possible selection options
                            //GroupBox {
                           identifiersList()
                            //}
                        }
                    }
                }

                
            }
        }
        
    }
    
    func identifiersList() -> some View {
        List(viewModel.characterNames, selection: $viewModel.selectedModifierText) { name in
                Text(name.value)
                    .tag(name.id)
                    .background(viewModel.selectedModifierText?.id == name.id ? .yellow : .clear)
            }.listStyle(.bordered)
    }
}

#Preview {
    RequestBuilderView()
}
