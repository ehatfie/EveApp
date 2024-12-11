//
//  AlgoHelperView.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/1/24.
//

import SwiftUI

@Observable class AlgoHelperViewModel {
  var dbManager: DBManager
  var searchText: String = "Arazu"
  var searchResults: [IdentifiedString] = []
  var selectedString: IdentifiedString? = IdentifiedString(
    id: 11969,
    value: "Arazu"
  )
  
  var inputs: [Int64: Int64]  = [:]
  
  var inputsDisplayable: [IdentifiedString] = []
  var inputGroups: [IPDetailInputGroup2] = []
  
  var jobsDisplayable: [DisplayableJob] = []
  var groupedJobs: [DisplayableJobsGroup] = []
  
  let ipm: IndustryPlannerManager
  let tool: IndyTool
  
  init(dbManager: DBManager) {
    self.dbManager = dbManager
    self.ipm = IndustryPlannerManager(dbManager: dbManager)
    self.tool = IndyTool(dbManager: dbManager)
  }
  
  func start() {
    guard let selectedString else { return }
    print("Start with \(selectedString.value)")
    
    Task {
//      guard let results = await ipm.breakdownInputs(
//        for: selectedString.id,
//        quantity: 1
//      ) else {
//        print("got no results")
//        return
//      }
      
      self.inputs = [:]
      self.inputsDisplayable = []
      let missingIputs = await tool.getMissingInputs(blueprintID: selectedString.id, quantity: 1)

      self.inputs = missingIputs
      let inputsDisplayable: [IdentifiedString] = ipm.makeDisplayable(from: missingIputs)
      self.inputsDisplayable = inputsDisplayable
      
      self.inputGroups = ipm.makeInputGroups(from: missingIputs)
      self.jobsDisplayable = await tool.makeDisplayableJobsForInputSums(inputs: missingIputs)
      self.groupedJobs = await tool.createGroupedJobs(jobs: self.jobsDisplayable)
    }
  }
  
  func search() {
    print("search for \(searchText)")
    let results = dbManager.searchTypeName(searchText: searchText)
    print("got \(results.count)")
    searchResults = results
  }
  
  func didSelect(_ value: IdentifiedString) {
    print("did select \(value.value)")
    self.selectedString = value
  }
}

struct AlgoHelperView: View {
  @State var viewModel: AlgoHelperViewModel
  @State var expanded: Set<String> = []
  
  var body: some View {
    VStack {
      Text("AlgoHelperView")
      
      TextFieldDropdownView(
        text: $viewModel.searchText,
        searchResults: $viewModel.searchResults,
        onSubmit: viewModel.search,
        didSelect: viewModel.didSelect
      )
      .border(.blue)
      
      Divider()
      HStack {
        VStack(alignment: .leading) {
          if let selectedString = viewModel.selectedString {
            Text("Selected: \(selectedString.value)")
          }
          ScrollView {
            inputs()
          }
          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
        VStack(alignment: .leading) {
          ScrollView {
            expandingListView(input: viewModel.inputGroups)
              .border(.blue)
            
            expandingListView(input: viewModel.groupedJobs)
              .border(.green)
          }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
      }
      Spacer()
      
      buttons()
    }
  }
  
  func inputs() -> some View {
    VStack(alignment: .leading) {
      Text("Inputs")
      
      ForEach(viewModel.inputsDisplayable, id: \.self) { input in
        HStack {
          Text(input.value + " \(input.id)")
          Spacer()
          Text("\(viewModel.inputs[input.id, default: 0])")
        }.frame(maxWidth: 300)
        
      }
    }
  }
  
  func jobs() -> some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("Jobs")
          .font(.headline)
        Spacer()
      }
      
      VStack(alignment: .leading, spacing: 5  ) {
        ForEach(viewModel.jobsDisplayable) { job in
          HStack {
            Text(job.blueprintName)
            Spacer()
            Text("\(job.requiredRuns)")
          }
          
        }
      }
    }
  }
  
  func buttons() -> some View {
    HStack {
      Button(action: {
        viewModel.start()
      }, label: {
        Text("Start")
      })
    }
  }
  
  func expandingListView(input: [DisplayableJobsGroup]) -> some View {
    VStack(alignment: .leading) {
      ForEach(input) { group in
        VStack(alignment: .leading, spacing: 5) {
          HStack {
            Text(group.groupName)
              .font(.headline)
            Text("\(group.numHave) / \(group.content.count)")
            Spacer()
          }.onTapGesture {
            if !expanded.insert(group.groupName).inserted {
              expanded.remove(group.groupName)
            }
          }
          
          if expanded.contains(group.groupName) {
            listView(content: group.content)
          }
          
        }
      }
    }
  }
  
  
  func expandingListView(input: [IPDetailInputGroup2]) -> some View {
    VStack(alignment: .leading) {
      ForEach(input) { group in
        VStack(alignment: .leading, spacing: 5) {
          HStack {
            Text(group.groupName)
              .font(.headline)
            Text("\(group.numHave) / \(group.content.count)")
            Spacer()
          }.onTapGesture {
            if !expanded.insert(group.groupName).inserted {
              expanded.remove(group.groupName)
            }
          }
          
          if expanded.contains(group.groupName) {
            listView(content: group.content)
          }
          
        }
      }
    }
  }
  
  func listView(content: [DisplayableJob]) -> some View {
    VStack(alignment: .leading) {
      ForEach(content) { value in
        VStack(alignment: .leading) {
          HStack(alignment: .center) {
            Text(value.blueprintName)
            Spacer()
            Text("\(value.requiredRuns)")
          }
          Divider().padding(.horizontal)
        }
        .padding(.horizontal)
      }
      //.frame(maxWidth: 300)
    }
    
  }
  
  
  func listView(content: [IPDetailInput1]) -> some View {
    VStack(alignment: .leading) {
      ForEach(content) { value in
        VStack(alignment: .leading) {
          HStack(alignment: .center) {
            Text(value.name)
            Spacer()
            VStack(alignment: .trailing) {
              HStack(alignment: .bottom, spacing: 3) {
                Text("\(value.quantity)")
                Text("required")
                  .font(.caption)
              }
              HStack(alignment: .bottom, spacing: 3) {
                Text("\(value.haveQuantity)")
                Text("available")
                  .font(.caption)
              }
             
            }
          }
          Divider().padding(.horizontal)
        }
        .padding(.horizontal)
      }
      //.frame(maxWidth: 300)
    }
  }
}

#Preview {
  AlgoHelperView(viewModel: AlgoHelperViewModel(dbManager: DBManager()))
}
