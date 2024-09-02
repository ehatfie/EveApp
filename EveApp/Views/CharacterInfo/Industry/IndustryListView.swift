//
//  IndustryListView.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/24/23.
//

import SwiftUI
import ModelLibrary

enum IndustryType {
    case manufacturing
    case science
    case reactions
}

struct CharacterIndustryInfo {
    let blueprintId: Int64
    let industryType: IndustryType
    let startTime: Date
    let endTime: Date
}

struct IndustryListView: View {
    var items: [GetCharactersIndustryJobsResponse]
    
    init() {
      self.items = [.value, .value2]
    }
    var body: some View {
        VStack {
            List(items, id: \.jobId) { item in
              HStack {
                VStack(alignment: .leading) {
                  Text("Blueprint Name")
                  Text("Runs - \(item.runs)")
                }

                VStack(alignment: .leading) {
                  Text("Start Date")
                  Text("End Date")
                }

                Text("Location Name")
              }
                
            }
        }
    }
}

#Preview {
    IndustryListView()
}

extension GetCharactersIndustryJobsResponse {
    static var value: Self {
        return GetCharactersIndustryJobsResponse(
            activityId: 0,
            blueprintId: 100,
            blueprintLocationId: 0,
            blueprintTypeId: 0,
            duration: 1000,
            endDate: "",
            facilityId: 0,
            installerId: 0,
            jobId: 0,
            outputLocationId: 0,
            runs: 10,
            startDate: "",
            stationId: 0,
            status: .active
        )
    }
  
  static var value2: Self {
      return GetCharactersIndustryJobsResponse(
          activityId: 1,
          blueprintId: 100,
          blueprintLocationId: 0,
          blueprintTypeId: 0,
          duration: 1000,
          endDate: "",
          facilityId: 0,
          installerId: 0,
          jobId: 1,
          outputLocationId: 0,
          runs: 10,
          startDate: "",
          stationId: 0,
          status: .active
      )
  }
}
