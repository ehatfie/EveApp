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
    
    func loadIndustryData() {
        Task {
            await DataManager.shared.fetchIndustryJobsForCharacters()
        }
    }
}

struct CharacterIndustryView: View {
    @State var viewModel: CharacterIndustryViewModel
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")  // set locale to reliable US_POSIX
        //dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.dateFormat = "MM/dd/yy hh:mm a"
        //          formatter.dateStyle = .long
        return dateFormatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            gridView()
//            Text("leading")
//            VStack(alignment: .leading, spacing: 10) {
//                ForEach(viewModel.industryJobs) { job in
//                    CharacterIndustryJobRow(industryJobDisplayable: job)
//                        .border(.blue)
//                }
//            }.border(.red)
            testButtons()
        }
    }
    
    func gridView() -> some View {
        Grid(alignment: .leading, verticalSpacing: 10) {
            GridRow(alignment: .top) {
                Group {
                    Text("Blueprint")
                    Text("Location ")
                    Text("Product")
                    Text("Start Date / End Date")
                    Text("Time Remaining")
                    Text("Runs")
                    Text("Status")
                }
            }
            
            ForEach(viewModel.industryJobs) { job in
                GridRow(alignment: .top) {
                    Text(job.blueprintName)
                    Text(job.blueprintLocationName)
                    Text("\(job.industryJobModel.runs) " + (job.productName ?? ""))
                    
                    VStack(alignment: .leading) {
                        Text(format(string: job.industryJobModel.startDate))
                            .font(.subheadline)
                        Text(format(string: job.industryJobModel.endDate))
                            .font(.subheadline)
                    }
                    
                    Text(timeRemaining(
                        dateString: job.industryJobModel.endDate,
                        duration: job.industryJobModel.duration
                    ))
                    Text("\(job.industryJobModel.runs)")
                    Text(job.industryJobModel.status.rawValue)
                }
            }
        }
    }
    
    func format(string: String) -> String {
        let date = try? Date(string, strategy: .iso8601)
        guard let date else { return "no_date" }
        return dateFormatter.string(from: date)
    }
    
    func timeRemaining(dateString: String, duration: Int) -> String {
        let endDate = try? Date(dateString, strategy: .iso8601)
        guard let endDate else { return "no_date" }
        let diff = endDate.timeIntervalSinceNow
        return secondsToTime(Int(diff))
    }
    
    func testButtons() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Button("load industry data") {
                    viewModel.loadIndustryData()
                }
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
        formatter.unitsStyle = .abbreviated
        
        let formattedString = formatter.string(from: TimeInterval(interval))!
        return formattedString
    }
}

#Preview {
    CharacterIndustryView(viewModel: CharacterIndustryViewModel())
}
