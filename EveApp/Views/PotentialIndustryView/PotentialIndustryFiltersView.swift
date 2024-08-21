//
//  PotentialIndustryFiltersView.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/29/24.
//

import SwiftUI
import TestPackage1

enum PotentialIndustryFilter: Hashable, CaseIterable, Identifiable {
    case completelyCompletable
    case partlyCompletable
    case hasBlueprint
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .completelyCompletable: "Full"
        case .partlyCompletable: "Part"
        case .hasBlueprint: "Have BP"
        }
    }
}

struct PIFilterGroup: Identifiable {
    var title: String
    var filters: [PIGroupFilterDisplayable]
    
    var id: String {
        title
    }
    
    init(title: String, filters: [PIGroupFilterDisplayable]) {
        self.title = title
        self.filters = filters
    }
}

struct PIGroupFilterDisplayable: Hashable, Identifiable {
    var id: Int {
        Int(groupID)
    }
    
    var groupID: Int64
    var title: String
    
    init(groupModel: GroupModel) {
        groupID = groupModel.groupId
        title = groupModel.name
    }
}

struct PotentialIndustryFiltersView: View {
    @State var selectedItems: Set<PotentialIndustryFilter>
    @Binding var selectedGroupFilters: Set<Int64>
    var groupFilters: [PIFilterGroup] = []
    
    var body: some View {
        HStack(alignment:.top) {
            FlowLayout(spacing: 10) {
                ForEach(PotentialIndustryFilter.allCases) { item in
                    Button(action: {
                       // insert or remove
                        if !selectedItems.insert(item).inserted {
                            _ = selectedItems.remove(item)
                        }
                    }) {
                        Text(item.title)
                    }.background(
                        selectedItems.contains(item)
                        ? Theme.filterButtonSelected
                        : Theme.filterButton)
                    //.foregroundStyle()
                }
            }
            
            VStack(alignment: .leading) {
                filterGroupsList()
            }
            
        }
    }
    
    func filterGroupsList() -> some View {
        HStack(alignment: .top) {
            ForEach(groupFilters) { filterGroups in
                VStack(alignment: .leading) {
                    Text(filterGroups.title)
                        .font(.headline)
                    FlowLayout(spacing: 10) {
                        HStack(alignment: .top) {
                            ForEach(filterGroups.filters) { item in
                                Button(action: {
                                    // insert or remove
                                    if !selectedGroupFilters.insert(item.groupID).inserted {
                                        _ = selectedGroupFilters.remove(item.groupID)
                                    }
                                }) {
                                    Text(item.title)
                                }
                                .background(
                                    selectedGroupFilters.contains(item.groupID)
                                        ? Theme.filterButtonSelected
                                        : Theme.filterButton
                                )
                                .cornerRadius(5)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PotentialIndustryFiltersView(
        selectedItems: Set<PotentialIndustryFilter>(),
        selectedGroupFilters: Binding<Set<Int64>>(get: { Set<Int64>() }, set: { _ in })
    )
}

// pinkish - Color(red: 183/255, green: 120/255, blue: 208/255)
