//
//  IPDetailView.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/23/24.
//

import SwiftUI

struct IPDetailModel {
  let blueprintName: String
  let inputs: [IPDetailInputGroup]
  let relatedAssets: [IPDetailInputGroup]
  let missingAssets: [IPDetailInputGroup]
  let jobs: [DisplayableJob]
}

struct IPDetailInput: Identifiable {
  let id: Int64
  let name: String
  let quantity: Int64
}

struct IPDetailInput1: Identifiable {
  let id: Int64
  let name: String
  let quantity: Int64
  let haveQuantity: Int64
}


struct IPDetailInputGroup: Identifiable {
  var id: String { groupName }
  let groupName: String
  let content: [IPDetailInput]
  let numHave: Int
}

struct IPDetailInputGroup2: Identifiable {
  var id: String { groupName }
  let groupName: String
  let groupID: Int64
  let content: [IPDetailInput1]
  let numHave: Int
}

/*

 struct IdentifiedString: Identifiable, Hashable {
   var id: Int64
   let value: String
   let content: [IdentifiedString]?

   init(id: Int64, value: String, content: [IdentifiedString]? = nil) {
     self.id = id
     self.value = value
     self.content = content
   }
}
 */

struct IPDetailView: View {
  let model: IPDetailModel

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(model.blueprintName)

      ScrollView {
        VStack(alignment: .leading, spacing: 10) {
          HStack(alignment: .top, spacing: 10) {
            listView(input: model.relatedAssets)
            
            VStack {
              listView(input: model.inputs)
              listView(input: model.missingAssets)
            }
          }
          VStack(alignment: .leading, spacing: 5) {
            Text("Jobs To Run")
              .font(.headline)
              .padding(.bottom, 5)
            ForEach(model.jobs) { value in
              jobRow(value)
            }
          }.frame(maxWidth: 300)
        }
      }.scrollBounceBehavior(.basedOnSize)
    }
  }
  func jobsList(input: [DisplayableJob]) -> some View {
    VStack {
      
    }
  }
  
  func jobRow(_ job: DisplayableJob) -> some View {
    VStack(alignment: .leading) {
      HStack {
        Text(job.blueprintName)
        Spacer()
        Text("\(job.requiredRuns)")
      }
      Divider().padding(.horizontal)
    }
    .padding(.horizontal)
  }
  
  func listView(input: [IPDetailInputGroup]) -> some View {
    VStack(alignment: .leading) {
      ForEach(input) { group in
        VStack(alignment: .leading, spacing: 5) {
          Text(group.groupName)
            .font(.headline)
          
          VStack(alignment: .leading) {
            ForEach(group.content) { value in
              VStack(alignment: .leading) {
                HStack {
                  Text(value.name)
                  Spacer()
                  Text("\(value.quantity)")
                }
                Divider().padding(.horizontal)
              }
              .padding(.horizontal)
            }
              .frame(maxWidth: 300)
          }
        }
      }
    }
  }

  func contentRow(input: IPDetailInput) -> some View {
    HStack {
      Text(input.name)
      Text("\(input.quantity)")
    }
  }
}

#Preview {
  IPDetailView(
    model: IPDetailModel(
      blueprintName: "Curse Blueprint",
      inputs: [],
      relatedAssets: [],
      missingAssets: [],
      jobs: []
    ))
}
