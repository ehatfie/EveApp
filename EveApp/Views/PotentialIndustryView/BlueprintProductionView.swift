//
//  BlueprintDetailView1.swift
//  EveApp
//
//  Created by Erik Hatfield on 8/16/24.
//

import SwiftUI

struct BlueprintProductionView: View {
    var shipPlan: ShipPlan
    
    var body: some View {
        VStack {
            Text("BlueprintProductionView")
        }
    }
}

#Preview {
    BlueprintProductionView(
        shipPlan: ShipPlan(
            jobs: .init(
                zeroLevelJobs: [
                    .init(
                        quantity: 1,
                        productId: 100,
                        inputs: [.init(quantity: 100, typeId: 101)],
                        blueprintId: 0,
                        productsPerRun: 0,
                        requiredRuns: 0
                    )
                ],
                firstLevelJobs: [],
                secondLevelJobs: [],
                thirdLevelJobs: []
            ), inputs: .empty
        )
    )
}
