//
//  AlgoHelperView.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/1/24.
//

import SwiftUI


@Observable class AlgoHelperViewModel {
  var dbManager: DBManager
  var searchText: String = "Sacrilege"
  var searchResults: [IdentifiedString] = []
  var selectedString: IdentifiedString? = IdentifiedString(
    id: 12019,
    value: "Sacrilege"
  )
  
  var inputs: [Int64: Int64]  = [:]
  
  var inputsDisplayable: [IdentifiedStringQuantity] = []
  var inputGroups: [IPDetailInputGroup2] = []
  
  var missingInputsDisplayable: [IdentifiedStringQuantity] = []
  var missingInputGroups: [IPDetailInputGroup2] = []
  
  var jobsDisplayable: [DisplayableJob] = []
  var groupedJobs: [DisplayableJobsGroup] = []
  
  let ipm: IndustryPlannerManager
  let tool: IndyTool
  
  var selectedCharacterId: String? = nil
  
  var selectedCharacterIdentifier: IdentifiedString? = nil
  var selectedCharacters: Set<IdentifiedString> = []
  var possibleCharacters: [IdentifiedString] = []
  
  var shoppingList: [IdentifiedStringQuantity] = []
  
  init(dbManager: DBManager) {
    self.dbManager = dbManager
    self.ipm = IndustryPlannerManager(dbManager: dbManager)
    self.tool = IndyTool(dbManager: dbManager)
    
    Task {
      await loadCharacters()
    }
  }
  
  func loadCharacters() async {
      print("loadCharacters")
      let characterInfo = await dbManager.getCharactersWithInfo()
      print("loadedCharacters")
      self.possibleCharacters = characterInfo
          .compactMap { characterData -> IdentifiedString? in
              guard
                  let characterId = Int64(characterData.characterId),
                  let publicData = characterData.publicData else {
                  return nil
              }
              
              return IdentifiedString(id: characterId, value: publicData.name)
          }
  }
  
  func start() {
    guard let selectedString else { return }
   
    if let selectedCharacter = selectedCharacters.first {
      tool.characterID = String(selectedCharacter.id)
    } else if let selectedCharacterIdentifier {
      tool.characterID = String(selectedCharacterIdentifier.id)
    } else {
      tool.characterID = nil
    }
    print("Start with \(selectedString.value) \(tool.characterID)")
    // tool.characterID = selectedCharacters.first?.id
    
    Task {
      self.inputs = [:]
      self.inputsDisplayable = []
//      let missingInputs = await tool.getMissingInputs(
//        blueprintID: selectedString.id,
//        quantity: 1
//      )
      let start2 = Date()
      var start = Date()
      //let missingInputs = await tool.getMissingInputs(values: [selectedString.id: 1])
      
      let missingInputs = await tool.testFindMissingInputs(values:  [selectedString.id: 1])

      print("++ missing inputs \(missingInputs)")
      print("first get missing inputs took \(Date().timeIntervalSince(start))")
      self.inputs = missingInputs
      
      start = Date()
      //let job = await tool.actuallyFindMissing(inputMaterials: missingInputs)
      let inputsDisplayable: [IdentifiedStringQuantity] = tool.makeGroupedDisplayable(from: missingInputs)
      
      self.inputsDisplayable = inputsDisplayable
      //makeInputGroups took 0.29674792289733887 for 14
      //self.inputGroups = ipm.makeInputGroups(from: missingInputs)
      //makeInputGroups took 0.2926030158996582 for 14
      start = Date()
      self.inputGroups = await tool.makeInputGroups(from: missingInputs)
      print("-- makeInputGroups took \(Date().timeIntervalSince(start))")
      
      start = Date()
      let jobs = await tool.testMakeJobsForMissingInputs(missingInputs: missingInputs)
      
      self.jobsDisplayable = await tool.makeDisplayableJobs(jobs)
//      self.jobsDisplayable = await tool.makeDisplayableJobsForInputSums(
//        inputs: missingInputs
//      )
      print("-- makeJobsDisplayableTook \(Date().timeIntervalSince(start))")
      start = Date()
      self.groupedJobs = await tool.createGroupedJobs(jobs: self.jobsDisplayable)
      print("-- createGroupedJobs took \(Date().timeIntervalSince(start))")
      self.shoppingList = await tool.getPurchaseListDisplayable(jobs: jobs)
      
      return
      
      var someValues: [Int64: Int64] = [:]
      
      for job in jobsDisplayable {
        someValues[job.id] = Int64(job.requiredRuns)
        if someValues[job.productId] != nil {
          
        }
      }
      
      //print("getting missing job inputs")
      start = Date()
      let missingJobInputs = await tool.getMissingInputs(values: someValues)
      print("-- second getMissingInputs took \(Date().timeIntervalSince(start))")
      print("missingJobInputs \(missingJobInputs.count)")
      let nonMadeMissingJobInputs = missingJobInputs.filter({ missingJobInput in
        return !jobsDisplayable.contains(where: { $0.productId == missingJobInput.key})
      })
      
      start = Date()
      self.missingInputsDisplayable = tool.makeGroupedDisplayable(from: nonMadeMissingJobInputs)
      print("-- makeGroupedDisplayable took \(Date().timeIntervalSince(start))")
      
      start = Date()
      self.missingInputGroups = ipm.makeInputGroups(from: nonMadeMissingJobInputs)
      
      print("-- makeInputGroups took \(Date().timeIntervalSince(start))")
      //let foo = tool.getPurchaseListDisplayable(jobs:)
      print("total took \(Date().timeIntervalSince(start2))")
      print("missingInputsDisplayable \(missingInputsDisplayable.count)")
    }
  }
  
  func search() {
    guard !searchText.isEmpty else {
      return
    }
    print("search for \(searchText)")
    let results = dbManager.searchTypeName(searchText: searchText)
    print("got \(results.count)")
    searchResults = results
  }
  
  func didSelect(_ value: IdentifiedString) {
    print("did select \(value.value)")
    self.selectedString = value
  }
  
  func setSelectedCharacter(characterId: String) {
    self.selectedCharacterId = characterId
  }
  
  func getMissingThingsString() -> String {
    var returnValue: String = ""
    let foo = missingInputGroups.flatMap { $0.content }
   // let bar = String(swiftLintMultiline: foo.map { $0.name + " \($0.quantity)"})
    returnValue = foo.reduce(into: "", { value, next in
      if !value.isEmpty {
        let nextValue = next.name + " \(next.quantity)"
        value += "\n" + nextValue
      } else {
        let nextValue = next.name + " \(next.quantity)"
        value += nextValue
      }
      
      
      return
    })
    
    return returnValue
  }
  
  
}

struct AlgoHelperView: View {
  @State var viewModel: AlgoHelperViewModel
  @State var expanded: Set<String> = []
  @State var expandedJobs: Set<String> = []
  
  var body: some View {
    VStack {
      Text("AlgoHelperView")
      HStack(alignment: .bottom) {
        TextFieldDropdownView(
          text: $viewModel.searchText,
          searchResults: $viewModel.searchResults,
          onSubmit: viewModel.search,
          didSelect: viewModel.didSelect
        )
        .border(.blue)
        
//        CharacterPickerView(
//          characterNames: $viewModel.possibleCharacters,
//          selectedCharacter: $viewModel.selectedCharacterIdentifier
//        )
        
        IPCharacterPickerView(
            selectedCharacters: $viewModel.selectedCharacters,
            possibleCharacters: viewModel.possibleCharacters
        )
        .frame(width: 300, height: 75)
      }
      
      Divider()
      HStack {
        VStack(alignment: .leading) {
          if let selectedString = viewModel.selectedString {
            Text("Selected: \(selectedString.value)")
          }
          
            makeList(viewModel.inputsDisplayable)
              .padding(.bottom, 10)
          makeList(viewModel.shoppingList)
          //makeList(viewModel)
          //makeList(viewModel.missingInputsDisplayable)
//          ScrollView {
//            missingInputs()
//          }
          Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
        VStack(alignment: .leading) {
          ScrollView {
//            expandingListView(input: viewModel.inputGroups)
//              .border(.blue)
//              .padding(.bottom, 10)
            
            expandingListView(input: viewModel.missingInputGroups)
              .border(.red)
              .padding(.bottom, 10)
            
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
  
  func missingInputs() -> some View {
    VStack(alignment: .leading) {
      Text("Missing Inputs \(viewModel.missingInputsDisplayable.count)")
      
      ForEach(viewModel.missingInputsDisplayable, id: \.self) { input in
        HStack {
          Text(input.value + " \(input.id)")
          Spacer()
          Text("\(viewModel.inputs[input.id, default: 0])")
        }.frame(maxWidth: 300)
        
      }
    }
  }
  
  func makeList(_ data: [IdentifiedStringQuantity]) -> some View {
    VStack {
      Text("Grouped inputs List \(data.count)")

        List {
            OutlineGroup(
                data,
                id: \.id,
                children: \.content
            ) { value in
                HStack {
                    Text(value.value)
                        .font(.subheadline)
                    Text(String(value.quantity))
                        .font(.subheadline)
                }
                
                
            }
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
      
      VStack(alignment: .leading, spacing: 5) {
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
      
      Button(action: {
        NSPasteboard.general.declareTypes([.string], owner: nil)

            let pasteboard = NSPasteboard.general // <----- This is important! Do not convert to a one liner!
        let string = viewModel.getMissingThingsString()
            pasteboard.setString(string, forType: .string)
        
      }, label: {
        Text("to clipboard")
      })
    }
  }
  
  func groupedInputsList() -> some View {
      VStack {
        Text("Grouped inputs List \(viewModel.inputsDisplayable.count)")

          List {
              OutlineGroup(
                  viewModel.inputsDisplayable,
                  id: \.id,
                  children: \.content
              ) { value in
                  HStack {
                    Text(value.value + " \(value.id)")
                          .font(.subheadline)
                      Text(String(value.quantity))
                          .font(.subheadline)
                  }
                  
                  
              }
          }
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
            if !expandedJobs.insert(group.groupName).inserted {
              expandedJobs.remove(group.groupName)
            }
          }
          
          if expandedJobs.contains(group.groupName) {
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

@Observable class CharacterSelectorViewModel {
  
}

struct CharacterSelectorView: View {
  let viewModel = CharacterSelectorViewModel()
  
  var body: some View {
    VStack {
      Text("Hello World")
    }
  }
}

extension String {

    init(swiftLintMultiline strings: String...) {
        self = strings.reduce("", +)
    }
}
