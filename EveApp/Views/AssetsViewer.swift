//
//  AssetsViewer.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/14/24.
//

import SwiftUI
import FluentSQLiteDriver

struct AssetsViewItem: Identifiable, Hashable {
    var id: String {
        return "\(typeId) + \(count)"
    }
    
    let typeId: Int64
    let name: String
    let count: Int
    let locationFlag: GetCharactersCharacterIdAssets200Ok.LocationFlag
    let locationType: GetCharactersCharacterIdAssets200Ok.LocationType
    
    init(
        typeId: Int64,
        name: String,
        count: Int,
        locationFlag: GetCharactersCharacterIdAssets200Ok.LocationFlag,
        locationType: GetCharactersCharacterIdAssets200Ok.LocationType
    ) {
        self.typeId = typeId
        self.name = name
        self.count = count
        self.locationFlag = locationFlag
        self.locationType = locationType
    }
    
    init(
        assetModel: CharacterAssetsDataModel,
        typeModel: TypeModel
    ) {
        self.init(
            typeId: assetModel.itemId,
            name: typeModel.name,
            count: assetModel.quantity,
            locationFlag:.init(rawValue: assetModel.locationFlag)!,
            locationType: .init(rawValue: assetModel.locationType)!
        )
    }
}

class AssetsViewerViewModel: ObservableObject {
    @Published var assets: [CharacterAssetsDataModel] = []
    @Published var viewItems: [AssetsViewItem] = []
    init() {
        
    }
    
    func fetchAssets() {
        //DataManager.shared.fetchAssets()
        //let assets = DataManager.shared.characterData!.assets
        //self.assets = DataManager.shared.characterData!.assets
        
        Task {
            await DataManager.shared.fetchAssetsAsync(mocked: false)
        }
    }
    
    func getAssets() {
        let thing = GetCharactersCharacterIdAssets200Ok.self
        Task {
            guard let character = await DataManager.shared.dbManager!.getCharacters().first else {
                print("fetchAssets() no character found")
                return
            }
            let db = await DataManager.shared.dbManager!.database
//            let assets = CharacterAssetsDataModel
//                .query(on: DataManager.shared.dbManager!.database)
                //.join(GroupModel.self, on: \GroupModel.$groupId == \TypeModel.$groupID)
            let foos = try await character.$assetsData.query(on: db)
                .join(TypeModel.self, on: \CharacterAssetsDataModel.$typeId == \TypeModel.$typeId)
                .all()
                .get()
            
            let allAssets = try await character.$assetsData.query(on: db)
                .all()
                .get()
            
            var set = Set<Int64>()
            
            foos.forEach { value in
                set.insert(value.typeId)
            }
            var set2 = Set<Int64>()
            
            allAssets.forEach { value in
                if !set.contains(value.typeId) {
                    set2.insert(value.typeId)
                }
            }
            
            print("types that didnt match \(set2)")
            print("got asset count \(foos.count)")
            let results = try foos.map { asset in
                let typeModel = try asset.joined(TypeModel.self)
                return AssetsViewItem(assetModel: asset, typeModel: typeModel)
            }
            
            DispatchQueue.main.async {
                self.viewItems = results
            }
        }
    }
    func deleteAssets() {
        Task {
            guard let character = await DataManager.shared.dbManager!.getCharacters().first else {
                print("deleteAssets() no character found")
                return
            }
            do {
               try await DataManager.shared.deleteAssets(characterModel: character)
            } catch let erro {
                print("delete assets error \(erro)")
            }
           
            
        }
    }
}

struct AssetsViewer: View {
    @ObservedObject var viewModel = AssetsViewerViewModel()
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            HStack {
                Button(action: {
                    viewModel.fetchAssets()
                }, label: {
                    Text("fetch assets")
                })
                
                Button(action: {
                    viewModel.getAssets()
                }, label: {
                    Text("get assets")
                })
                
                Button(action: {
                    viewModel.deleteAssets()
                }, label: {
                    Text("delete assets")
                })
            }

            VStack(alignment: .leading) {
                List(viewModel.viewItems , id: \.id) { value in
                    VStack {
                        HStack {
                            Text(value.name)
                            Text("\(value.count)")
                        }
                        HStack {
                            Text(value.locationFlag.rawValue)
                            Text(value.locationType.rawValue)
                        }
                    }
                }
//                List(viewModel.assets, id: \.id ) { value in
//                    VStack(alignment: .leading) {
//                        Text("itemId: \(value.itemId)")
//                        Text("typeId: \(value.typeId)")
//                        Text("quantity: \(value.quantity)")
//                    }
//
//                }
            }
        }
    }
}

#Preview {
    AssetsViewer(viewModel: AssetsViewerViewModel())
}
