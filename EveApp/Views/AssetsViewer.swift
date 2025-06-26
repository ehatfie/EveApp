//
//  AssetsViewer.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/14/24.
//

import SwiftUI
import FluentSQLiteDriver
import ModelLibrary


struct AssetsViewItem: Identifiable, Hashable {
    var id: String {
        return "\(typeId) + \(count)"
    }
    
    let typeId: Int64
    let name: String
    let count: Int
    let locationFlag: GetCharactersCharacterIdAssets200Ok.LocationFlag
    let locationType: GetCharactersCharacterIdAssets200Ok.LocationType
    let locationId: Int64
    let locationName: String
    
    init(
        typeId: Int64,
        name: String,
        count: Int,
        locationFlag: GetCharactersCharacterIdAssets200Ok.LocationFlag,
        locationType: GetCharactersCharacterIdAssets200Ok.LocationType,
        locationId: Int64,
        locationName: String?
    ) {
        self.typeId = typeId
        self.name = name
        self.count = count
        self.locationFlag = locationFlag
        self.locationType = locationType
        self.locationId = locationId
        self.locationName = locationName ?? String(locationId)
    }
    
    init(
        assetModel: CharacterAssetsDataModel,
        typeModel: TypeModel,
        stationInfoModel: StationInfoModel?
    ) {
        
        self.init(
            typeId: assetModel.itemId,
            name: typeModel.name,
            count: Int(assetModel.quantity),
            locationFlag:.init(rawValue: assetModel.locationFlag)!,
            locationType: .init(rawValue: assetModel.locationType)!,
            locationId: assetModel.locationId,
            locationName: stationInfoModel?.name
        )
    }
}

@Observable class AssetsViewerViewModel {
    var assets: [CharacterAssetsDataModel] = []
    var viewItems: [AssetsViewItem] = []
    
    var selectedCharacter: IdentifiedString = IdentifiedString(id: 0, value: "")
    var availableCharacters: [IdentifiedString] = []
    
    var characterAssets: [CharacterAssetsDataModel] = []
    var allAssetLocations: [IdentifiedString] = []
    
    var groupedAssets: [IdentifiedStringQuantity] = []
    var groupedSum: Int = 0
    var totalSum: Int = 0
    
    init() {
        Task {
            await loadCharacters()
            await testThing()
        }
        
    }
    
    func loadCharacters() async {
        let dbManager = await DataManager.shared.dbManager!
        
        let characters = await dbManager.getCharactersWithInfo()
        
        let identifiedStrings = characters.compactMap { character -> IdentifiedString? in
            guard let publicData = character.publicData else { return nil }
            guard let characterId = Int64(character.characterId) else { return nil }
            return IdentifiedString(id: characterId, value: publicData.name)
        }
        if let first = identifiedStrings.first {
            self.selectedCharacter = first
        }
        self.availableCharacters = identifiedStrings
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
        Task {
            await makeSortedAssets()
            return
            let dbManager = await DataManager.shared.dbManager!
            
            //            guard let character = await DataManager.shared.dbManager!.getCharacters().first else {
            //                print("fetchAssets() no character found")
            //                return
            //            }
            //let db = await DataManager.shared.dbManager!.database
            let selectedCharacterId = String(selectedCharacter.id)
            guard let characterAssets = await dbManager.getAssetsForCharacter(characterId: selectedCharacterId) else {
                print("got no character assets for selected character \(selectedCharacter.id) \(selectedCharacter.value)")
                return
            }
            
//            if let allCharacterAssets = await dbManager.getAllAssetsForCharacter(characterId: selectedCharacterId) {
//                totalSum = allCharacterAssets.count
//            }
            //await DataManager.shared.fetchLocations(assets: characterAssets)
            print("got asset count \(characterAssets.count)")
            let results = try characterAssets.map { asset in
                let typeModel = try asset.joined(TypeModel.self)
                //let stationInfoModel = try asset.joined(StationInfoModel.self)
                
                return AssetsViewItem(
                    assetModel: asset,
                    typeModel: typeModel,
                    stationInfoModel: nil//stationInfoModel
                )
            }
            self.characterAssets = characterAssets
            
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
    
    func fetchAssetLocations() {
        print("FetchAssetLocations")
        guard !characterAssets.isEmpty else {
            print("++ no assets")
            return
        }
        
        Task {
            await DataManager.shared.fetchLocations(assets: characterAssets)
        }
    }
    
    func fetchMissingLocations() {
        let locationIds = self.groupedAssets.map { $0.id }
        Task {
            await DataManager.shared.fetchLocations(locationIds: locationIds)
        }
    }
    
    func getAssetLocations() {
        print("GetAssetLocations")
        Task {
            let dbManager = await DataManager.shared.dbManager!
            do {
                let stationInfoModels = try await StationInfoModel.query(on: dbManager.database).all()
                let identifiedStrings = stationInfoModels.map { IdentifiedString(id: $0.stationId, value: $0.name)}
                
                allAssetLocations = identifiedStrings
            } catch let error {
                print("++ StationInfoModel query error \(String(reflecting: error))")
            }
        }
    }
    
    func makeSortedAssets() async {
        let dbManager = await DataManager.shared.dbManager!
        
        let values = await dbManager.getAssetsTest(characterId: String(selectedCharacter.id))
        self.groupedAssets = values
    }
    
    func makeSortedAssets1() async {
        print("++ makeSortedAssets")
        let dbManager = await DataManager.shared.dbManager!
        
        var assetsByLocation: [IdentifiedStringQuantity: [CharacterAssetsDataModel]] = [:]
        
        for characterAsset in characterAssets {
            guard let locationInfo = try? characterAsset.joined(StationInfoModel.self) else {
                print("++ no locationInfo for character asset")
                continue
            }
            
            let key = IdentifiedStringQuantity(
                id: characterAsset.locationId,
                value: locationInfo.name,
                quantity: 0
            )
            
            assetsByLocation[key, default: []] += [characterAsset]
        }
        
        var sortedItems: [IdentifiedStringQuantity] = []
        var sortedCount = 0
        
        for locationAssets in assetsByLocation {
            let location = locationAssets.key
            let assets = locationAssets.value
            
            let identifiedAssets = assets.compactMap { asset -> IdentifiedStringQuantity? in
                guard let typeModel = try? asset.joined(TypeModel.self) else {
                    print("++ no joined typeModel")
                    return nil
                }
                // using itemId so we dont have duplicates, assuming thats what its for
                
                return IdentifiedStringQuantity(
                    id: asset.itemId,
                    value: typeModel.name,
                    quantity: asset.quantity
                )
            }

            let stationInfoModel = await DataManager.shared.dbManager?.getStationInfoModel(
                stationId: location.id
            )

            sortedItems.append(
                IdentifiedStringQuantity(
                    id: location.id,
                    value: location.value,
                    quantity: Int64(identifiedAssets.count),
                    content: identifiedAssets
                )
            )
            sortedCount += identifiedAssets.count
        }

        self.groupedAssets = sortedItems
        self.groupedSum = sortedCount
    }
    
    func testThing() async {
        
    }
}

struct AssetsViewer: View {
    @State var viewModel = AssetsViewerViewModel()
    
    var body: some View {
        VStack {
            Text("Assets Viewer")
            IdentifiedStringPickerView(
                selectedIdentifier: $viewModel.selectedCharacter,
                options: viewModel.availableCharacters
            )
            HStack {
                Button(action: {
                    viewModel.fetchAssets()
                }, label: {
                    Text("Fetch assets")
                })
                
                Button(action: {
                    viewModel.getAssets()
                }, label: {
                    Text("Get assets")
                })
                
                Button(action: {
                    viewModel.fetchAssetLocations()
                }, label: {
                    Text("Fetch asset locations")
                })
                
                Button(action: {
                    viewModel.getAssetLocations()
                }, label: {
                    Text("Get asset locations")
                })
                
                Button(action: {
                    viewModel.fetchMissingLocations()
                }, label: {
                    Text("Fetch missing locations")
                })
            }
            HStack {
                //assetsList()
                groupedAssetsList()
                
                if !viewModel.allAssetLocations.isEmpty {
                    locationsList()
                }
                
            }
            
        }
    }
    
    func characterList() -> some View {
        VStack {
            
        }
    }
    
    func assetsList() -> some View {
        VStack(alignment: .leading) {
            Text("Assets List \(viewModel.viewItems.count) total \(viewModel.totalSum)")
            List(viewModel.viewItems , id: \.id) { value in
                VStack(alignment: .leading) {
                    HStack {
                        Text(value.name)
                        Text("\(value.count)")
                    }
                    HStack {
                        Text(value.locationFlag.rawValue)
                        Text(value.locationType.rawValue)
                    }
                    if value.locationName.isEmpty {
                        Text("\(value.locationId)")
                    } else {
                        Text(value.locationName)
                    }
                }
            }
        }
    }
    
    func groupedAssetsList() -> some View {
        VStack {
            Text("Grouped Assets List \(viewModel.groupedSum)")

            List {
                OutlineGroup(
                    viewModel.groupedAssets,
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
    
    func locationsList() -> some View {
        VStack {
            Text("Locations List")
            List(viewModel.allAssetLocations) { stationInfo in
                Text(stationInfo.value)
            }
        }
    }
}

#Preview {
    AssetsViewer(viewModel: AssetsViewerViewModel())
}
