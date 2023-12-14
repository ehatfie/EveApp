//
//  BlueprintIndustryView.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/15/23.
//

import SwiftUI
import Combine
import Fluent

struct BlueprintIndustryView: View {
    @State var blueprint: BlueprintModel
    let typeModel: TypeModel
    
    @State var groups: String = ""
    
    init() {
        let dbManager = DataManager.shared.dbManager!
        let blueprint = dbManager.getRandomBlueprint()!
        self.blueprint = blueprint
        self.typeModel = dbManager.getType(for: blueprint.blueprintTypeID)
        //print("got blueprint \(blueprint)")
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            BlueprintDetailView(blueprint: blueprint)
                .border(.orange)
            Spacer()
            RandomBlueprintPicker(blueprint: $blueprint)
//            HStack {
//                Button(action: {
//                    self.blueprint = DataManager.shared.dbManager!.getRandomBlueprint()
//                }, label: {
//                  Text("Random Blueprint")
//                })
//                randomBlueprintPicker().frame(height: 200)
//            }
        }
    }
    
    func randomBlueprintPicker() -> some View {
        let groups = DataManager.shared.dbManager?.getCategories() ?? []
        print("got \(groups.count) groups")
        return HStack {
            Text("Picker Label:")
            Picker("Picker", selection: $groups, content: {
                ForEach(groups, id: \.categoryId) { group in
                    Text(group.name).tag(group.name)
                }
//                VStack {
//                    ForEach(groups, id: \.groupId) { group in
//                        Text(group.name)
//                    }
//                }
            })
        }
    }
}

#Preview {
    BlueprintIndustryView()
}


struct RandomBlueprintPicker: View {
    @Binding var blueprint: BlueprintModel
    @State var selectedCategory: CategoryModel? = CategoryModel(
        id: 0,
        data: CategoryData(
            name: ThingName(name: "Name"),
            published: false
        )
    )
    @State var selectedGroup: GroupModel?
    @State var categories: [CategoryModel]?
    @State var groups: [GroupModel]? = nil
    
    init(blueprint: Binding<BlueprintModel>) {
        self._blueprint = blueprint
        self.categories = nil
    }
    
    func getCategories() {
        self.categories = DataManager.shared.dbManager?.getCategories() ?? []
    }
    
    func getGroups(in categoryId: Int64) {
        print("get groups in \(categoryId)")
        self.groups = DataManager.shared.dbManager?.getGroups(in: categoryId)
    }
    
    var body: some View {
        HStack {
            Button(action: {
                self.blueprint = DataManager.shared.dbManager!.getRandomBlueprint()!
            }, label: {
              Text("Random Blueprint")
            })
//            if let categories = self.categories {
//                Picker("Category Picker", selection: $selectedCategory) {
//                    ForEach(categories, id: \.categoryId) { category in
//                        Text(category.name).tag(category.categoryId)
//                    }
//                }
//                //.onReceive(Just(selectedCategory), perform: { category in
////                    print("selected category \(category)")
////                    if let selectedCategory = category {
////                        self.getGroups(in: selectedCategory.categoryId)
////                    }
////                })
//
//                .onChange(of: selectedCategory) { category in
//                    if let selectedCategory = category {
//                        self.getGroups(in: selectedCategory.categoryId)
//                    }
//                    
//                }
//            }
//            if let groups = self.groups {
//                Picker("Group Picker", selection: $selectedGroup) {
//                    ForEach(groups, id: \.groupId) { group in
//                        Text(group.name).tag(group.groupId)
//                    }
//                }.onChange(of: selectedGroup) { selectedGroup in
//                    print("selected group \(selectedGroup?.name)")
//                }
//            }
        }.onAppear {
            //self.getCategories()
        }
    }
}

extension CategoryModel: Equatable, Hashable {
    static func == (lhs: CategoryModel, rhs: CategoryModel) -> Bool {
        lhs.categoryId < rhs.categoryId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(categoryId)
        //hasher.combine(label)
        //hasher.combine(command)
    }
}

extension GroupModel: Equatable, Hashable {
    static func == (lhs: GroupModel, rhs: GroupModel) -> Bool {
        lhs.groupId < rhs.groupId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(groupId)
        //hasher.combine(label)
        //hasher.combine(command)
    }
}
