//
//  DevelopHelperView.swift
//  EveApp
//
//  Created by Erik Hatfield on 12/13/23.
//

import SwiftUI
import Fluent

struct DevelopHelperView: View {
  @EnvironmentObject var homeViewModel: HomeViewModel
  
  @State var showThing: Bool = false
  
    var body: some View {
        VStack {
          Text("Test")
            Button(action: {
              Task {
                await DataManager.shared.dbManager?.deleteAll()
              }
            }, label: {
              Text("Clear Database")
            })
          
          Button(action: {
            showThing = true
          }, label: {
            Text("Delete some models")
          })
        }.sheet(isPresented: $showThing, content: {
          selectModelsToDeleteView()
        })
        
    }
  
  func selectModelsToDeleteView() -> some View {
    /*
     
     try await deleteType(GroupModel.self),
     try await deleteType(CategoryModel.self),
     try await deleteType(TypeModel.self),
     try await deleteType(DogmaEffectModel.self),
     try await deleteType(DogmaAttributeModel.self),
     try await deleteType(DogmaAttributeCategoryModel.self),
     try await deleteType(TypeDogmaInfoModel.self),
     try await deleteType(TypeMaterialsModel.self)
     */

    
    return ModelSelectorView(showThing: $showThing)
  }
}


struct ModelSelectorView: View {
  @State var viewItems: [ModelPickerData]
  @State private var multiSelection = Set<UUID>()
  
  @Binding var showThing: Bool
  
  //@State var isEditMode: EditMode = .inactive
  
  init(showThing: Binding<Bool>) {
    let items: [any Model.Type] = [
      GroupModel.self,
      CategoryModel.self,
      TypeModel.self,
      DogmaEffectModel.self,
      DogmaAttributeModel.self,
      DogmaAttributeCategoryModel.self,
      TypeDogmaInfoModel.self,
      TypeMaterialsModel.self
    ]
    
    self.viewItems = items.map { value -> ModelPickerData in
      return ModelPickerData(value)
    }
    
    self._showThing = showThing
  }
  
  var body: some View {
    return VStack {
    
      Text("Pick things to delete")
        .padding(10)
      
      List(self.viewItems, id: \.id) { type in
        //Text(type.testType.schema)
        ModelSelectorRow(isSelected: multiSelection.contains(type.id), text: type.testType.schema)
          .onTapGesture {
            print("insert \(type.testType.schema)")
            multiSelection.insert(type.id)
          }
      }
      .padding([.horizontal, .bottom], 10)
      HStack {
        Button(action: {
          let foo = viewItems.filter({multiSelection.contains($0.id)}).map{$0.testType}
          DataManager.shared.dbManager?.deleteTypes(foo)
        }, label: {
          Text("submit")
        })
        Button(action: {
          self.showThing = false
        }, label: {
          Text("Cancel")
        })
        
        Button(action: {
          for item in viewItems {
            self.multiSelection.insert(item.id)
          }
        }, label: {
          Text("All")
        })
      }.padding(15)
    }.frame(minWidth: 300, minHeight: 350)
  }
}

struct ModelSelectorRow: View {
  @State var isSelected: Bool
  let text: String
  
  var body: some View {
    VStack {
      HStack {
        Text(text)

        Spacer()
      }

    }.padding(.leading, 10)
      .onTapGesture {
        self.isSelected.toggle()
      }
      .background($isSelected.wrappedValue ? .blue : .clear)
  }
}


struct ModelPickerData: Identifiable {
  var id: UUID
  var testType: any Model.Type
  var name: String
  
  init(_ type: any Model.Type) {
    id = UUID()
    testType = type
    name = testType.schema
  }
}

#Preview {
  DevelopHelperView()
      .environmentObject(HomeViewModel())
}
