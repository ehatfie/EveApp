//
//  KillboardView.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/25/24.
//

import SwiftUI
import ModelLibrary
import Fluent
import Charts

struct ChartItem: Identifiable, Hashable {
    var id: UUID
    let value: String
    let count: Int64
    let content: [ChartItem]?

    init(id: UUID, value: String, count: Int64, content: [ChartItem]? = nil) {
        self.id = id
        self.value = value
        self.count = count
        self.content = content
    }
}

@Observable class KillboardProcessorViewModel {
    var killmailCount: Int = 0
    var killmails: [MERKillmailDisplayable] = []
    var someData: [ChartItem] = []
    
    var dictionary: [String: Int64] = [:]
    
    init() {
        loadKillmails()
    }
    
    func loadKillmails() {
        let dbManager = DataManager.shared.dbManager!
        let itemsCount = try? MERKillmailModel.query(on: dbManager.database)
            .count()
            .wait()
        
        self.killmailCount = itemsCount ?? -1
        print("set killmail count")
        Task {
            print("start task")
            var time = Date()
            //var dictionary: [String: Int] = [:]
            try? await MERKillmailModel.query(on: dbManager.database)
                .field(\.$id).field(\.$regionName).field(\.$victimShipGroupName)
                .field(\.$iskLost)
                .filter(\.$victimShipGroupName ~~ ["Marauder", "Dreadnought"])
                .chunk(max: 128) { killmails in
                    for killmail in killmails{
                        guard let km = try? killmail.get() else { continue }
                        self.increment(regionName: km.regionName, value: km.iskLost)
                    }
                }
            print("got killmails took \(Date().timeIntervalSince(time))")
            time = Date()

            print("counted killmails \(Date().timeIntervalSince(time))")
            time = Date()
//            let items = dictionary.map { ChartItem(id: UUID(), value: $0.key, count: $0.value) }
//            print("created items \(Date().timeIntervalSince(time))")
//            someData = items
            var regionDict: [String: Int64] = [:]
            for value in dictionary {
                var systemClass: String
                let regionName = value.key
                if regionName == "Pochven" ||
                    Substring(regionName)[2] == "-" {
                    systemClass = "Pochven"
                } else {
                    let initialLetter = Substring(regionName)[0]
                    
                    print("initial letter \(initialLetter)")
                    switch initialLetter {
                    case "A":
                        systemClass = "C1"
                    case "B":
                        systemClass = "C2"
                    case "C":
                        systemClass = "C3"
                    case "D":
                        systemClass = "C4"
                    case "E":
                        systemClass = "C5"
                    case "F":
                        systemClass = "C6"
                    default:
                        continue
                    }
                    regionDict["All WH", default: 0] += value.value
                }
                
                regionDict[systemClass, default: 0] += value.value
                
            }
            
            var items = regionDict.sorted(by: { $0.key < $1.key }).map { ChartItem(id: UUID(), value: $0.key, count: $0.value) }
            items.move(fromOffsets: IndexSet(0...0), toOffset: regionDict.count - 1)
            print("created items \(Date().timeIntervalSince(time))")
            someData = items
            
            let regionNames = dictionary.map { $0.key }
            
            print("region names \(regionNames)")
            
            //.init(color: "Green", type: "Cube", count: 2),
            //.init(class: "C1", type: "dread", isk: 100)
            //self.killmails = (killmails ?? []).map { MERKillmailDisplayable(model: $0 )}
        }
        
    }
    
    func increment(regionName: String, value: Int64) {
        if Substring(regionName)[1] == "-" {
            dictionary[regionName, default: 0] += value
        } else if regionName == "Pochven" || Substring(regionName)[2] == "-" {
            dictionary[regionName, default: 0] += value
        } else {
            print("ss1 \(Substring(regionName)[0...2]) ss2 \(Substring(regionName)[2])")
            return }
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}

struct MERKillmailDisplayable: Identifiable {
    var id: AnyHashable {
        model.id!
    }
    
    let model: MERKillmailModel
}

struct KillboardView: View {
    @State var viewModel: KillboardProcessorViewModel = .init()
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            HStack {
                Button("Load") {
                    viewModel.loadData()
                }
            }
            Text("Loaded Killmails: \(viewModel.killmailCount)")
            VStack(alignment: .leading) {
                
                Text("Marauders + Dreadnoughts killed in March 2025")
                Chart {
                    ForEach(viewModel.someData) { value in
                        BarMark(
                            x: .value("Count", value.count),
                            y: .value("Region", value.value)
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    KillboardView()
}



extension KillboardProcessorViewModel {
    func loadData() {
        Task {
            if let path = Bundle.main.path(forResource: "kill_dump", ofType: "json") {
                do {
                      let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                      let decoder = JSONDecoder()
                    let items = try decoder.decode([MERKillmailData].self, from: data)
                    print("loaded \(items.count) json items")
                    var idSet: Set<String> = []
                    let models: [MERKillmailModel] = items.compactMap { data in
                        let uniqueId = data.kill_datetime + "\(data.isk_lost)" + data.victim_corporation_name + data.killer_corporation_name
                        guard idSet.insert(uniqueId).inserted else {
                            return nil
                        }
                        return MERKillmailModel(data: data)
                    }
                    
                    print("created \(models.count) merkillmail models")
                    let dbManager = await DataManager.shared.dbManager!
                    
                    let modelCount = models.count
                    
                    let top = Array(models[0 ..< modelCount / 2])
                    let bottom = Array(models[modelCount / 2 ..< modelCount])
                    
                    
                    let topCount = top.count
                    let top1 = Array(top[0 ..< topCount / 2])
                    let top2 = Array(top[topCount / 2 ..< topCount])
                    print("saving \(top1.count)")
                    try await dbManager.splitAndSaveAsync(splits: 6, models: top1)
                    try await dbManager.splitAndSaveAsync(splits: 6, models: top2)
                    
                    let bottomCount = bottom.count
                    let bot1 = Array(bottom[0 ..< bottomCount / 2])
                    let bot2 = Array(bottom[bottomCount / 2 ..< bottomCount])
                    try await dbManager.splitAndSaveAsync(splits: 6, models: bot1)
                    try await dbManager.splitAndSaveAsync(splits: 6, models: bot2)
                    //try await dbManager.splitAndSaveAsync(splits: 8, models: bottom)
//                    try await models.create(on: dbManager.database)
//                        .get()
                    print("saved \(models.count) merkillmail models")
                  } catch let error {
                       // handle error
                      print("json load error \(String(reflecting: error))")
                  }
            }
        }
    }
}

extension Double {
    func reduceScale(to places: Int) -> Double {
        
        let multiplier = Double.pow(10, Double(places))
        let newDecimal = multiplier * self // move the decimal right
        let truncated = Double(Int(newDecimal)) // drop the fraction
        let originalDecimal = truncated / multiplier // move the decimal back
        return originalDecimal
    }
}

extension Int64 {
    var asFormattedString: String {
        let num = abs(Double(self))
        let sign = self < 0 ? "-" : ""

        switch num {
        case 1_000_000_000...:
            return "\(sign)\((num / 1_000_000_000).reduceScale(to: 1))B"
        case 1_000_000...:
            return "\(sign)\((num / 1_000_000).reduceScale(to: 1))M"
        case 1_000...:
            return "\(sign)\((num / 1_000).reduceScale(to: 1))K"
        case 0...:
            return "\(self)"
        default:
            return "\(sign)\(self)"
        }
    }
}
