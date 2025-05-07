//
//  AttributeAllocator.swift
//  EveApp
//
//  Created by Erik Hatfield on 4/28/25.
//

import SwiftUI

enum AttributeEnum: String, CaseIterable, Identifiable {
    var id: Int64 {
        attributeId
    }
    case perception
    case memory
    case willpower
    case intelligence
    case charisma
    
    init?(value: Int) {
        switch value {
        case 165: self = .intelligence
        case 166: self = .memory
        case 167: self = .perception
        case 168: self = .willpower
        case 169: self = .charisma
        default: return nil
        }
    }
    
    var attributeId: Int64 {
        switch self {
        case .intelligence: return 165
        case .memory: return 166
        case .perception: return 167
        case .willpower: return 168
        case .charisma: return 169
        }
    }
}

@Observable class AttributeValues {
    let minimumValue: Int = 17
    let modifierMax: Int = 10
    
    var availablePoints: Int = 14
    
    
    var perceptionModifier: Int = 0
    var willpowerModifier: Int = 0
    var intelligenceModifier: Int = 0
    var memoryModifier: Int = 0
    var charismaModifier: Int = 0
    
    func value(for attribute: AttributeEnum) -> Int {
        let modifier: Int
        switch attribute {
        case .intelligence: modifier = intelligenceModifier
        case .charisma: modifier = charismaModifier
        case .memory: modifier = memoryModifier
        case .perception: modifier = perceptionModifier
        case .willpower: modifier = willpowerModifier
        }
        return modifier + minimumValue
    }
}

struct AttributeAllocator: View {
    @Binding var attributeValues: AttributeValues
    @Binding var remaps: Int
    @State var maxRemaps: Int = 3
    
    let maxModifier: Int = 10
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Available Points: \(attributeValues.availablePoints)")
                AttributeAllocatorThing(
                    minValue: 0,
                    maxModifier: maxModifier,
                    modifier: $remaps,
                    availablePoints: $maxRemaps,
                    name: "Remaps"
                )
            }
            
            VStack {
                HStack {
                    AttributeAllocatorThing(
                        minValue: attributeValues.minimumValue,
                        maxModifier: maxModifier,
                        modifier: $attributeValues.perceptionModifier,
                        availablePoints: $attributeValues.availablePoints,
                        name: "Perception"
                    )
                    AttributeAllocatorThing(
                        minValue: attributeValues.minimumValue,
                        maxModifier: maxModifier,
                        modifier: $attributeValues.willpowerModifier,
                        availablePoints: $attributeValues.availablePoints,
                        name: "Willpower"
                    )
                }

                HStack {
                    AttributeAllocatorThing(
                        minValue: attributeValues.minimumValue,
                        maxModifier: maxModifier,
                        modifier: $attributeValues.intelligenceModifier,
                        availablePoints: $attributeValues.availablePoints,
                        name: "Intelligence"
                    )
                    AttributeAllocatorThing(
                        minValue: attributeValues.minimumValue,
                        maxModifier: maxModifier,
                        modifier: $attributeValues.memoryModifier,
                        availablePoints: $attributeValues.availablePoints,
                        name: "Memory"
                    )
                    AttributeAllocatorThing(
                        minValue: attributeValues.minimumValue,
                        maxModifier: maxModifier,
                        modifier: $attributeValues.charismaModifier,
                        availablePoints: $attributeValues.availablePoints,
                        name: "Charisma"
                    )
                }
            }
        }
    }
}

struct AttributeAllocatorThing: View {
    let minValue: Int
    let maxModifier: Int
    @Binding var modifier: Int
    @Binding var availablePoints: Int
    
    let name: String
    
    var body: some View {
        VStack {
            Text(name)
            HStack {
                Button("-") {
                    if modifier > 0 {
                        modifier -= 1
                        availablePoints += 1
                    }
                }
                .disabled(modifier == 0)
                Text("\(minValue + modifier)")
                Button("+") {
                    if modifier < maxModifier {
                        modifier += 1
                        availablePoints -= 1
                    }
                    
                }
                .disabled(availablePoints <= 0 || modifier == maxModifier)
            }
            
        }
    }
}

#Preview {
    AttributeAllocator(
        attributeValues: .constant(AttributeValues()),
        remaps: .constant(0)
    )
}
