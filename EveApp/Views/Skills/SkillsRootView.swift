//
//  SkillsRootView.swift
//  EveApp
//
//  Created by Erik Hatfield on 4/28/25.
//

import Foundation
import SwiftUI
import ModelLibrary
import Fluent

struct SkillInfo: Identifiable {
    var id: Int64 {
        typeModel.typeId + Int64(requiredLevel)
    }
    let typeModel: TypeModel
    let dogma: TypeDogmaInfoModel
    let skillDogmaInfo: SkillDogmaAttributeInfo
    let skillEffectInfo: SkillEffectInfo
    let skillDescription: String
    let requiredLevel: Int
    var spNeeded: Int {
        let skillMultiplyer = skillDogmaInfo.skillMiscAttributes.skillTimeConstant
        let requiredLevelMod = max(requiredLevel - 1, 0)
        let powValue = pow(32, requiredLevelMod)
        let sqrtValue = sqrt(powValue.primitivePlottable)
        
        let value = 250.0 * Double(skillMultiplyer) * sqrtValue
        return Int(value.rounded(.down))
    }
    
    var primaryAttribute: DogmaAttributeModel {
        skillDogmaInfo.skillMiscAttributes.primaryAttribute
    }
    
    var secondaryAttribute: DogmaAttributeModel {
        skillDogmaInfo.skillMiscAttributes.secondaryAttribute
    }
}

struct RemapThing: Identifiable {
    var id: Int64 {
        primaryAttributeId + secondaryAttributeId
    }
    let primaryAttributeId: Int64
    let secondaryAttributeId: Int64
    
    var primaryEnum: AttributeEnum {
        return AttributeEnum(value: Int(primaryAttributeId))!
    }
    
    var secondaryEnum: AttributeEnum {
        return AttributeEnum(value: Int(secondaryAttributeId))!
    }
}

let mockString: String = """
    Precursor Cruiser 5
    Cybernetics 5
    Heavy Assault Cruisers 1
    Heavy Assault Cruisers 2
    Heavy Assault Cruisers 3
    Heavy Assault Cruisers 4
    Heavy Assault Cruisers 5
    Shield Compensation 5
    Target Management 4
    Motion Prediction 5
    """

@Observable class SkillsViewModel {
    let dbManager: DBManager
    var skillInfos: [SkillInfo] = []
    
    var attributeValues = AttributeValues()
    var numRemaps: Int = 1
    
    var primaryAttributeSp: [Int64: Int64] = [:]
    var secondaryAttributeSp: [Int64: Int64] = [:]
    
    init() {
        self.dbManager = DataManager.shared.dbManager!
    }
    
    func submit(_ textFieldValue: String) {
        let splitStrings = textFieldValue.split(separator: "\n").dropLast()
        var returnArray: [SkillThing] = []
        var skillValues = splitStrings.compactMap { value -> (String, Int)? in
            let skillName = value.dropLast(2)
            guard
                let last = value.last,
                last.isNumber,
                let skillLevel = Int(String(last))
            else { return nil }
            return (String(skillName), skillLevel)
        }
        Task {
            let results = await dbManager.makeSkillInfos(for: skillValues)
            
            self.skillInfos = results.sorted { one, two in
                guard one.id != two.id else {
                    return one.requiredLevel < two.requiredLevel
                }
                return one.id < two.id
            }
            
            // 250 × multiplier × sqrt(pow(32, level − 1))
        }
        
        //(SP needed − Current SP) / (Primary Attribute + (Secondary Attribute /2))
        //SP/minute = Primary_Attribute + 0.50 × Secondary_Attribute
    }
    
    func skillTrainTime(
        primaryAttribute: AttributeEnum,
        secondaryAttribute: AttributeEnum,
        sp: Int
    ) -> Int {
        let primaryValue = attributeValues.value(for: primaryAttribute)
        let secondaryValue = attributeValues.value(for: secondaryAttribute)
        
        let spMin: Double = Double(primaryValue) + (0.5 * Double(secondaryValue))
        
        return Int(Double(sp)/spMin)
    }
    
    func skillTrainTime(_ skillInfo: SkillInfo) -> Int {
        let primary = skillInfo.skillDogmaInfo.skillMiscAttributes.primaryAttribute
        let secondary = skillInfo.skillDogmaInfo.skillMiscAttributes.secondaryAttribute
        return skillTrainTime(
            primaryAttribute: AttributeEnum(value: Int(primary.attributeID))!,
            secondaryAttribute: AttributeEnum(value: Int(secondary.attributeID))!,
            sp: skillInfo.spNeeded
        )
    }
    
    func totalTime() -> Int {
        var totalTime: Int = 0
        
        for skillInfo in skillInfos {
            totalTime += skillTrainTime(skillInfo)//.secondsToTime()
        }
        return totalTime
    }
    
    func calculateTime(attributeEnum: AttributeEnum, spAmount: Int64) -> Int {
        let attributeValue = attributeValues.value(for: attributeEnum) + 20
        return Int(spAmount / Int64(attributeValue))
    }
    
    func analyze() {
        var categorizedSkills: [Int64: [SkillInfo]] = [:]
        
        
        for skillInfo in skillInfos {
            let primaryAttribute = skillInfo.primaryAttribute
            let secondaryAttribute = skillInfo.secondaryAttribute
            
            let primaryTime = Int64(skillInfo.spNeeded)
            let secondaryTime = Int64(floor(Double(skillInfo.spNeeded) * 0.5))
            
            primaryAttributeSp[primaryAttribute.attributeID, default: 0] += primaryTime
            secondaryAttributeSp[secondaryAttribute.attributeID, default: 0] += secondaryTime
            
            let existing = categorizedSkills[primaryAttribute.attributeID, default: []]
            categorizedSkills[primaryAttribute.attributeID, default: []] = existing + [skillInfo]
        }
    }
    
    func bestRemaps() -> [RemapThing] {
        guard !skillInfos.isEmpty else { return [] }
        guard !primaryAttributeSp.isEmpty && !secondaryAttributeSp.isEmpty else { return [] }
        var bestRemaps: [RemapThing] = []
        
        var primaryCopy = primaryAttributeSp
        var secondaryCopy = secondaryAttributeSp
        
        
        while bestRemaps.count < numRemaps {
            var bestPrimary: Int64 = 0
            var bestSecondary: Int64 = 0
            
            for (key, value) in primaryCopy {
                let bestPrimaryValue = primaryCopy[bestPrimary, default: 0]
                if value > bestPrimaryValue {
                    bestPrimary = key
                }
            }
            
            for (key, value) in secondaryCopy {
                let bestSecondaryValue = secondaryCopy[bestSecondary, default: 0]
                if value > bestSecondaryValue && key != bestSecondary {
                    bestSecondary = key
                }
            }
            
            primaryCopy.removeValue(forKey: bestPrimary)
            secondaryCopy.removeValue(forKey: bestSecondary)
            bestRemaps.append(RemapThing(primaryAttributeId: bestPrimary, secondaryAttributeId: bestSecondary))
        }
        
        return bestRemaps
    }
}

struct SkillThing {
    let skillId: Int64
    let skillName: String
    let requiredLevel: Int
}

struct SkillsRootView: View {
    @State var viewModel: SkillsViewModel = SkillsViewModel()
    @State var textValue: String = mockString
    
    var body: some View {
        HStack(alignment: .top) {
            VStack {
                TextEditor(text: $textValue)
                    .frame(maxWidth: 200, maxHeight: 300)
                Button("Submit") {
                    viewModel.submit(textValue)
                }
            }
            
            VStack {
                AttributeAllocator(attributeValues: $viewModel.attributeValues, remaps: $viewModel.numRemaps)
                HStack {
                    Text("\(viewModel.totalTime().secondsToTime())")
                    Button("Analyze") {
                        viewModel.analyze()
                    }
                }
                
                List(viewModel.skillInfos, id: \.id) { skillInfo in
                    VStack(alignment: .leading) {
                        Text("\(skillInfo.skillDescription) \(skillInfo.requiredLevel)")
                        
                        HStack {
                            attribute(skillInfo.skillDogmaInfo.skillMiscAttributes.primaryAttribute)
                            Text(" | ")
                            attribute(skillInfo.skillDogmaInfo.skillMiscAttributes.secondaryAttribute)
                            Text("\(skillInfo.skillDogmaInfo.skillMiscAttributes.skillTimeConstant)x")
                            Text("\(skillInfo.spNeeded)")
                        }
                        
                        HStack {
                            skillTime(skillInfo)
                        }
                    }
                }
                HStack {
                    attributeGrid()
                    bestRemaps()
                    Spacer()
                }
            }
            Spacer()
        }
        .padding()
        .frame(alignment: .leading)
        
    }
    
    @ViewBuilder
    func skillTime(_ skillInfo: SkillInfo) -> some View {
        let time = viewModel.skillTrainTime(skillInfo).secondsToTime()
        Text(time)
    }
    
    @ViewBuilder
    func attribute(_ dogma: DogmaAttributeModel) -> some View {
        //let attribute =
        Text("\(dogma.name)")
    }
    
    @ViewBuilder
    func totalTime() -> some View {
        
    }
    
    @ViewBuilder
    func attributeGrid() -> some View {
        
        Grid(alignment: .leading, verticalSpacing: 10) {
            GridRow(alignment: .top) {
                Group {
                    Text("")
                    Text("Primary")
                    Text("Secondary")
                    Text("Total")
                    Text("Time")
                }
            }
            
            ForEach(AttributeEnum.allCases) { value in
                let primaryAttributeSp = viewModel.primaryAttributeSp[value.attributeId, default: 0]
                let secondaryAttributeSp = viewModel.secondaryAttributeSp[value.attributeId, default: 0]
                let totalAttributeSp = primaryAttributeSp + secondaryAttributeSp
                let spThing = viewModel.calculateTime(attributeEnum: value, spAmount: totalAttributeSp)
                GridRow(alignment: .bottom) {
                    Text(value.rawValue)
                    Text("\(primaryAttributeSp)")
                    Text("\(secondaryAttributeSp)")
                    Text("\(totalAttributeSp)")
                    Text("\(spThing.secondsToTime())")
                }
            }
        }
    }
    
    @ViewBuilder
    func bestRemaps() -> some View {
        VStack {
            Text("Best Remaps")
            ForEach(viewModel.bestRemaps()) { remap in
                HStack {
                    Text(remap.primaryEnum.rawValue)
                    Text(remap.secondaryEnum.rawValue)
                }
            }
        }

    }
}

#Preview {
    SkillsRootView()
}


extension Int {
    func secondsToHoursMinutesSeconds() -> (Int, Int, Int) {
        return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
    }
    
    func secondsToTime() -> String {
        let interval = self
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        
        let formattedString = formatter.string(from: TimeInterval(interval))!
        return formattedString
    }
}
