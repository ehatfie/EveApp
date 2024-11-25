//
//  CharacterIndustryView.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/15/24.
//

import FluentSQL
import ModelLibrary
import SwiftUI

@Observable class CharacterIndustryViewModel {
    var industryJobs: [IndustryJobDisplayable] = []
    let dbManager: DBManager
    
    init() {
        self.dbManager = DataManager.shared.dbManager!
        Task {
            await getIndustryJobs()
        }
    }
    
    func getIndustryJobs() async {
        let jobs = await dbManager.getIndustryJobModels()
        let viewData = try? await dbManager.getIndustryJobDisplayInfo(
            data: jobs)
        self.industryJobs = viewData ?? []
        //self.industryJobs = jobs.map { IndustryJobDisplayable(industryJobModel: $0) }
    }
    
    func loadIndustryData() async {
        await DataManager.shared.fetchIndustryJobsForCharacters()
    }
    
}

struct CharacterIndustryView: View {
    @State var viewModel: CharacterIndustryViewModel
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")  // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //          formatter.dateStyle = .long
        return dateFormatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("leading")
            VStack(alignment: .leading, spacing: 10) {
                ForEach(viewModel.industryJobs) { job in
                    CharacterIndustryJobRow(industryJobDisplayable: job)
                        .border(.blue)
                }
            }.border(.red)
            testButtons()
        }
    }
    
    func testButtons() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Button(
                    action: {
                        Task {
                            await viewModel.loadIndustryData()
                        }
                        
                    },
                    label: {
                        Text("load industry data")
                    })
            }
        }
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func secondsToTime(_ seconds: Int) -> String {
        let interval = seconds
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        
        let formattedString = formatter.string(from: TimeInterval(interval))!
        print(formattedString)
        return formattedString
    }
}

#Preview {
    CharacterIndustryView(viewModel: CharacterIndustryViewModel())
}
