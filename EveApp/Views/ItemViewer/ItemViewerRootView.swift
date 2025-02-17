//
//  ItemViewerRootView.swift
//  EveApp
//
//  Created by Erik Hatfield on 2/5/25.
//

import SwiftUI
import Fluent
import FluentSQL
import ModelLibrary
import FluentKit

@Observable class ItemViewerRootViewModel {
    var sidebarItems: [IdentifiedString] = [
        IdentifiedString(id: 0, value: "Test", content: [
            IdentifiedString(id: 1, value: "Inner", content: [
                IdentifiedString(id: 2, value: "Another")
            ])
        ])
    ]
    let dbManager: DBManager
    
    init() {
        self.dbManager = DataManager.shared.dbManager!
        Task {
           await load()
        }
    }
    
    func load() async {
        let dbManager = await DataManager.shared.dbManager!
        let marketGroups = try! await MarketGroupModel.query(on: dbManager.database)
            .filter(\.$parentGroupId == nil)
            .all()
            .sorted(by: { $0.name < $1.name })
        
//        let values = marketGroups.map { marketGroup in
//            let children = self.getChildren(for: Int(marketGroup.marketGroupId))
//            return IdentifiedString(
//                id: Int64(marketGroup.marketGroupId),
//                value: marketGroup.name,
//                content: children.map { IdentifiedString(
//                    id: Int64($0.marketGroupId),
//                    value: $0.name)
//                }
//            )
//        }
        let start = Date()
        //sidebarItems = makeContent()
        sidebarItems = await makeContentAsync(dbManager)
        print("sidebarItems took \(Date().timeIntervalSince(start))")
    }
    
    func getChildren(for parentGroupId: Int) -> [MarketGroupModel] {
        let marketGroups = try! MarketGroupModel.query(on: dbManager.database)
            .filter(\.$parentGroupId == parentGroupId)
            .all()
            .wait()
        //print("got \(marketGroups.count) children for \(parentGroupId)")
        return marketGroups
    }
    
    func getChildrenAsync(for parentGroupId: Int) async -> [MarketGroupModel] {
        let marketGroups = try! await MarketGroupModel.query(on: dbManager.database)
            .filter(\.$parentGroupId == parentGroupId)
            .all()
            .get()
        //print("got \(marketGroups.count) children for \(parentGroupId)")
        return marketGroups
    }
    
    func makeContent() -> [IdentifiedString] {
        let marketGroups = try! MarketGroupModel.query(on: dbManager.database)
            .filter(\.$parentGroupId == nil)
            .all()
            .wait()
            .sorted(by: { $0.name < $1.name })
        
        let values = marketGroups.map { marketGroupModel in
            return self.makeContent(for: marketGroupModel)
        }
        
        return values
    }
    
    func makeContent(for marketGroupModel: MarketGroupModel) -> IdentifiedString {
        guard !marketGroupModel.hasTypes else {
            return makeItemContent(for: marketGroupModel)
        }
        let children = self.getChildren(for: Int(marketGroupModel.marketGroupId))
        let childrenIdentifiedStrings: [IdentifiedString] = children.map { makeContent(for: $0) }
        
        return IdentifiedString(
            id: Int64(marketGroupModel.marketGroupId),
            value: marketGroupModel.name,
            content: childrenIdentifiedStrings
        )
    }
    
    func makeItemContent(for marketGroupModel: MarketGroupModel) -> IdentifiedString {
        let items = try! TypeModel.query(on: DataManager.shared.dbManager!.database)
            .filter(\.$marketGroupID == marketGroupModel.marketGroupId)
            .all()
            .wait()
        
        let strings = items.map { IdentifiedString(id: $0.typeId, value: $0.name)}
        return IdentifiedString(
            id: Int64(marketGroupModel.marketGroupId),
            value: marketGroupModel.name
        )
    }
    
    func makeItemContentAsync(for marketGroupModel: MarketGroupModel, _ dbManager: DBManager) async -> IdentifiedString {
        let startDate = Date()
        let items = await getItemsForMarketGroupAsync(
            marketGroupID: marketGroupModel.marketGroupId,
            dbManager
        )
        
        //print("makeContentAsync fetch \(Date().timeIntervalSince(startDate))")
        
        let strings = items.map { IdentifiedString(id: $0.typeId, value: $0.name)}
        return IdentifiedString(
            id: Int64(marketGroupModel.marketGroupId),
            value: marketGroupModel.name,
            content: strings
        )
    }
    
    func getItemsForMarketGroupAsync(marketGroupID: Int, _ dbManager: DBManager) async -> [TypeModel] {
        let items = try! await TypeModel.query(on: dbManager.database)
            .filter(\.$marketGroupID == marketGroupID)
            .all()
            .get()
        return items
    }
}
// async implementations
extension ItemViewerRootViewModel {
    
    func makeContentAsync(_ dbManager: DBManager) async -> [IdentifiedString] {
        let marketGroups = try! await MarketGroupModel.query(on: dbManager.database)
            .filter(\.$parentGroupId == nil)
            .all()
            .sorted(by: { $0.name < $1.name })
        
        let returnValues = await withTaskGroup(
            of: IdentifiedString.self,
            returning: [IdentifiedString].self) { taskGroup in
                for marketGroup in marketGroups {
                    taskGroup.addTask {
                        return await self.makeContentAsync(for: marketGroup, dbManager)
                    }
                }
                var returnValues = [IdentifiedString]()
                for await result in taskGroup {
                    returnValues.append(result)
                }
                return returnValues
            }
        return returnValues
    }
    
    func makeContentAsync(for marketGroupModel: MarketGroupModel, _ dbManager: DBManager) async -> IdentifiedString {
        guard !marketGroupModel.hasTypes else {
            let start = Date()
            let results = await makeItemContentAsync(for: marketGroupModel, dbManager)
            print("getting items took \(Date().timeIntervalSince(start))")
            return results
        }
        let children = await self.getChildrenAsync(for: Int(marketGroupModel.marketGroupId))
        
        let childrenIdentifiedStrings = await withTaskGroup(
            of: IdentifiedString.self,
            returning: [IdentifiedString].self) { taskGroup in
                for marketGroup in children {
                    taskGroup.addTask {
                        return await self.makeContentAsync(for: marketGroup, dbManager)
                    }
                }
                var returnValues = [IdentifiedString]()
                for await result in taskGroup {
                    returnValues.append(result)
                }
                return returnValues
            }
        
        //let childrenIdentifiedStrings: [IdentifiedString] = children.map { makeContent(for: $0) }
        
        return IdentifiedString(
            id: Int64(marketGroupModel.marketGroupId),
            value: marketGroupModel.name,
            content: childrenIdentifiedStrings
        )
    }
}

struct ItemViewerRootView: View {
    var viewModel: ItemViewerRootViewModel = ItemViewerRootViewModel()
    var body: some View {
        NavigationSplitView(sidebar: {
            //VStack {
            List {
                OutlineGroup(
                    viewModel.sidebarItems,
                    id: \.id,
                    children: \.content
                ) { value in
                    Text(value.value).font(.subheadline)
                            
                }.listStyle(SidebarListStyle())
            }
        }) {
        }
    }
}

#Preview {
    ItemViewerRootView()
}
