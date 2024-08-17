//
//  BlueprintDetailView.swift
//  EveApp
//
//  Created by Erik Hatfield on 10/26/23.
//

import SwiftUI
import Fluent

@Observable class BlueprintDetailViewModel {
  let industryPlanner: IndustryPlannerManager
  var shipPlan: ShipPlan = .empty
  
  init(industryPlanner: IndustryPlannerManager) {
    self.industryPlanner = industryPlanner
  }
  
  func makePlan(blueprint: BlueprintModel) {
    Task {
      let plan = await self.industryPlanner.makePlan(for: blueprint)
      print("makePlan result \(plan)")
      self.shipPlan = plan
    }
  }
}

struct BlueprintDetailView: View {
  var blueprint: BlueprintModel
  var typeModel: TypeModel?
  
  let industryPlanner: IndustryPlannerManager
  
  @State var shipPlan: ShipPlan = .empty
  var viewModel: BlueprintDetailViewModel
  
  init(blueprint: BlueprintModel, industryPlanner: IndustryPlannerManager) {
    let db = DataManager.shared.dbManager!.database
    
    self.blueprint = blueprint
    self.industryPlanner = industryPlanner

    
    let foo = try! TypeModel.query(on: db)
      .filter(\.$typeId == blueprint.blueprintTypeID)
      .first()
      .wait()
    
    self.typeModel = foo
    self.viewModel = BlueprintDetailViewModel(industryPlanner: industryPlanner)
    self.viewModel.makePlan(blueprint: blueprint)
  }
  

  // 45648
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        if let typeModel = self.typeModel {
          Text("\(typeModel.name)")
            .font(.title)
          Text("\(typeModel.groupID)")
          Text("\(typeModel.typeId)")
        }
      }
      
      HStack {
//        activitiesView(for: blueprint.activities)
//          .border(.yellow)
//        BlueprintComponentView(blueprintModel: blueprint)
//          .border(.purple)
        
        VStack(alignment: .leading) {
          inputsView(for: viewModel.shipPlan.inputs)
          shipPlanView(for: viewModel.shipPlan)
          Spacer()
        }
        
//        if let industryPlan = self.industryPlanner.makePlan3(for: blueprint) {
//          industryPlanView(for: industryPlan)
//        }
//        
        //componentsView(for: blueprint.activities.manufacturing)
      }
      
    }
  }
  
  func format(seconds: Int) -> String {
    String(format:"%d:%02d", seconds / 60, seconds % 60)
  }
  
  func activitiesView(for model: BlueprintActivityModel) -> some View {
    
    let copyTime = Duration(
      secondsComponent: 60,
      attosecondsComponent: 0
    )
    
    let manufacturingTime = Duration(
      secondsComponent: model.manufacturing.time / 1,
      attosecondsComponent: 0
    )
    
    return VStack(alignment: .leading) {
      Text("Activities View")
      manufacturingView(for: model.manufacturing)
      HStack {
        Text("copying time: ")
        Text(copyTime.formatted())
      }
      
      HStack {
        Text("Manufacturing Time:")
        Text(manufacturingTime.formatted())
      }
      Spacer()
    }
  }
  
  func manufacturingView(for model: BlueprintManufacturingModel) -> some View {
    return VStack(alignment: .leading, spacing: 15) {
      MaterialDetailView(
        title: "Materials",
        materials: model.materials
      )
      MaterialDetailView(
        title: "Products",
        materials: model.products
      )
    }//.border(.red)
  }
  
  func componentsView(for model: BlueprintManufacturingModel) -> some View {
    let typeIds = model.materials.map { $0.typeId }
    let types = DataManager.shared.dbManager!.getTypes(for: typeIds)
    
    let foo = zip(model.materials, types)
    
    
    return VStack(){
      
      Text("Components View")
      List(types, id: \.id) { material in
        typeMaterialView(for: material)
      }
      Spacer()
      
    }
  }
  
  func typeMaterialView(for type: TypeModel) -> some View {
    let materialTypes = DataManager.shared.dbManager?
      .getTypeMaterialModel(for: type.typeId)//?.materialData ?? []
    
    //    let foo = MaterialDetailView(
    //      title: "Materials",
    //      materials: materialTypes?.materialData.map { value in
    //        QuantityTypeModel(
    //      }
    //    )
    return VStack {
      Text(type.name)
      
      if materialTypes?.materialData.count ?? 0 > 0 {
        MaterialDetailView(
          title: "Materials",
          materials: materialTypes?.materialData ?? []
        ).border(.black)
      }
      
    }
  }
  
  func industryPlanView(for model: IndustryPlanJob) -> some View {
    return VStack {
      Text(model.blueprintTypeModel.name)
      
      List(model.inputMaterials, id: \.typeModel.typeId) { input in
        IndustryPlanInfoView(inputMaterialInfo: input)
      }
    }
  }
  
  func shipPlanView(for plan: ShipPlan) -> some View {
    let jobs = plan.jobs.zeroLevelJobs
    //let keys = plan.jobs.zeroLevelJobs.map { $0.blueprintId }
    let model = plan.jobs
    
    var keys = model.zeroLevelJobs.map { $0.blueprintId }
    
    keys += model.firstLevelJobs.map { $0.blueprintId }
    keys += model.secondLevelJobs.map { $0.blueprintId }
    keys += model.thirdLevelJobs.map { $0.blueprintId }
    
    var names: [Int64: String] = [:]
    
    industryPlanner.dbManager.getTypeNames(for: keys)
      .forEach { value in
        names[value.typeId] = value.name
      }
    
    let zeroLevelValues: [(Int64, String, Int)]
    = model.zeroLevelJobs.map { value in
      return (value.blueprintId, names[value.blueprintId] ?? "NA", value.requiredRuns)
    }.sorted(by: { $0.0 < $1.0})
    
    let firstLevelValues = model.firstLevelJobs.map { value in
        return (value.blueprintId, names[value.blueprintId] ?? "NA", value.requiredRuns)
    }.sorted(by: { $0.0 < $1.0})
    
    let secondLevelValues = model.secondLevelJobs.map { value in
        return (value.blueprintId, names[value.blueprintId] ?? "NA", value.requiredRuns)
    }.sorted(by: { $0.0 < $1.0})
    
    let thirdLevelValues = model.thirdLevelJobs.map { value in
      return (value.blueprintId, names[value.blueprintId] ?? "NA", value.requiredRuns)
    }.sorted(by: { $0.0 < $1.0})
    
    
    return //ScrollView {
      HStack(alignment: .top) {
        inputListView("First Level", values: zeroLevelValues)
        inputListView("Second Level", values: firstLevelValues)
        inputListView("Third Level", values: secondLevelValues)
       // inputListView("Third Level", values: thirdLevelValues)
      }
   // }
  }
  
  func inputsView(for model: ShipPlanInputs) -> some View {
    var names: [Int64: String] = [:]
    //let firstKeys = model.firstLevelInputs.keys.map { Int($0) }
    
    let keys = 
    model.zeroLevelInputs.keys.map { $0 }
    + model.firstLevelInputs.keys.map { $0 }
    + model.secondLevelInputs.keys.map { $0 }
    + model.thirdLevelInputs.keys.map { $0 }
    
    // get name for inputs
    industryPlanner.dbManager.getTypeNames(for: keys)
      .forEach { value in
        names[value.typeId] = value.name
      }
    
    let zeroLevelValues = model.zeroLevelInputs.map { key, value in
      return (key, names[key] ?? "", value)
    }.sorted(by: { $0.0 < $1.0})
    
    let firstLevelValues = model.firstLevelInputs.map { key, value in
        return (key, names[key] ?? "", value)
    }.sorted(by: { $0.0 < $1.0})
    
    let secondLevelValues = model.secondLevelInputs.map { key, value in
        return (key, names[key] ?? "", value)
    }.sorted(by: { $0.0 < $1.0})
    
    let thirdLevelValues = model.thirdLevelInputs.map { key, value in
        return (key, names[key] ?? "", value)
    }.sorted(by: { $0.0 < $1.0})
    
    
    return VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .top) {
        inputListView("Zero Level \(zeroLevelValues.count)", values: zeroLevelValues)
        inputListView("First Level", values: firstLevelValues)
        inputListView("Second Level", values: secondLevelValues)
        inputListView("Third Level", values: thirdLevelValues)
      }
      Spacer()
    }.frame(maxHeight: .infinity)
    .border(.blue)
  }
  
  func inputListView(_ text: String, values: [(Int64, String, Int)]) -> some View {
      VStack(alignment: .leading, spacing: 5) {
        Text(text).font(.title2)
        Divider()
        List(values, id: \.0) { entry in
          HStack(alignment: .center) {
            Text("\(entry.1)")
            Spacer()
            Text("\(entry.2)")
          }
        }
        Spacer()
      }.frame(maxWidth: 250)
  }
  
  func jobListView(_ text: String, values: [(Int64, String, Int)]) -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 5) {
        Text(text).font(.title2)
        Divider()
        ForEach(values, id: \.0) { entry in
          HStack(alignment: .center) {
            Text("\(entry.1)")
            Spacer()
            Text("\(entry.2)")
          }
        }
        Spacer()
      }.frame(maxWidth: 250)
    }
  }
}

//#Preview {
//    BlueprintDetailView()
//}



