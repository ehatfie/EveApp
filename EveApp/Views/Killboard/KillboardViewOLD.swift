//
//  KillboardView.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/10/24.
//

import SwiftUI
import ModelLibrary
import FluentKit

@Observable class KillboardViewModel {
    var text: String = ""
    
    var responseData: [ZKillmailModel] = []
    var esiModels: [ESIKillmailModel] = []
    
    var selectedKillmail: ZKillmailModel? = nil
    var selectedKillmailInfo: EveKmData? = nil
    var killmailDisplayInfo: [KillmailDisplayInfo] = []
    
    init() {
        loadModels()
        Task {
            await self.loadDisplayData2()
        }
    }
    
    func processTextInput() {
        let decoder = JSONDecoder()
        do {
            let data = text.data(using: .utf8, allowLossyConversion: false)!
            let result = try decoder.decode([ZKillResponseData].self, from: data)
            print("got result \(result)")
            //self.responseData = result
            Task {
                await self.saveZKillModels(data: result)
                let dbModels = try await ZKillmailModel.query(on: DataManager.shared.dbManager!.database)
                    .all()
                    .get()
                self.responseData = dbModels
                
                let esiInfo = dbModels.map {($0.killmailId, $0.hash)}
                await self.fetchESIKillmails(for: esiInfo)
            }
            
        } catch let err {
            print("process text err \(err)")
        }
    }
    
    func loadModels() {
        let db = DataManager.shared.dbManager!.database
        let dbModels = try? ZKillmailModel.query(on: db)
            .all()
            .wait()
        self.responseData = dbModels ?? []
        
        let esiModels = (try? ESIKillmailModel.query(on: db)
            .all()
            .wait()) ?? []
        print("loaded esi models \(esiModels.count)")
        self.esiModels = esiModels
    }
    
    func loadDisplayData() async {
        let dbManager = await DataManager.shared.dbManager!
        //      .join(TypeMaterialsModel.self, on: \TypeMaterialsModel.$typeID == \TypeModel.$typeId)
        let killmails = (
            try? await ZKillmailModel.query(on: dbManager.database)
                .join(ESIKillmailModel.self, on: \ZKillmailModel.$killmailId == \ESIKillmailModel.$killmailId)
                .join(SolarSystemModel.self, on: \SolarSystemModel.$systemID == \ESIKillmailModel.$solarSystemId)
                .all()
        ) ?? []
        
        var characterDict: [Int64: CharacterIdentifiersModel] = [:]
        
        let characterIdentifiers = (try? await CharacterIdentifiersModel.query(on: dbManager.database)
            .all()) ?? []
        
        for value in characterIdentifiers {
            characterDict[value.characterID] = value
        }
        
        let killmailIds = killmails.map { $0.killmailId }
        print("killmailIds: \(killmailIds.count)")
        let displayInfo = killmails.compactMap { zKillmail -> KillmailDisplayInfo? in
            guard
                let esiKillmail = try? zKillmail.joined(ESIKillmailModel.self),
                let solarSystemInfo = try? zKillmail.joined(SolarSystemModel.self)
            else {
                return nil
            }
            
            let attackersInfo: [CharacterIdentifiersModel] = esiKillmail.attackers
                .compactMap({ attacker in
                    guard let characterId = attacker.characterId else {
                        return nil
                    }
                    return characterDict[characterId]
                })
            guard let victimId = esiKillmail.victim.first?.characterId,
                  let victimInfo: CharacterIdentifiersModel = characterDict[victimId]
            else {
                return nil
            }
            
            return KillmailDisplayInfo(
                zkill: zKillmail,
                esi: esiKillmail,
                systemName: solarSystemInfo.name,
                attackersIdentifiers: attackersInfo,
                victimIdentifier: victimInfo, victimShipName: ""
            )
        }
        print("got killmails \(killmails.count)")
        self.killmailDisplayInfo = displayInfo
    }
    
    func loadDisplayData2() async {
        let dbManager = await DataManager.shared.dbManager!
        var characterDict: [Int64: CharacterIdentifiersModel] = [:]
        
        let characterIdentifiers = (try? await CharacterIdentifiersModel.query(on: dbManager.database)
            .all()) ?? []
        
        for value in characterIdentifiers {
            characterDict[value.characterID] = value
        }
        
        let killmails = await DataManager.shared.dbManager!.getAllESIKillMailModels()
        
        let displayInfo = killmails.compactMap { esiKillmail -> KillmailDisplayInfo? in
            guard
                let zKillmail = try? esiKillmail.joined(ZKillmailModel.self),
                let solarSystemInfo = try? esiKillmail.joined(SolarSystemModel.self)
            else {
                return nil
            }
            
            let attackersInfo: [CharacterIdentifiersModel] = esiKillmail.attackers
                .compactMap({ attacker in
                    guard let characterId = attacker.characterId else {
                        return nil
                    }
                    return characterDict[characterId]
                })
            guard let victimId = esiKillmail.victim.first?.characterId,
                  let victimInfo: CharacterIdentifiersModel = characterDict[victimId]
            else {
                return nil
            }
            var shipName: String = "SOME SHIP"
            if let shipTypeID = esiKillmail.victim.first?.shipTypeId {
                shipName = dbManager.getTypeNames(for: [shipTypeID])[0].name
            }//.map(\.name)
            return KillmailDisplayInfo(
                zkill: zKillmail,
                esi: esiKillmail,
                systemName: solarSystemInfo.name,
                attackersIdentifiers: attackersInfo,
                victimIdentifier: victimInfo,
                victimShipName: shipName
            )
        }
        self.killmailDisplayInfo = displayInfo
    }
    
    func loadText() {
        let userDefaults = UserDefaults.standard
        if let existing = userDefaults.value(forKey: "kmText") as? String {
            self.text = existing
        }
    }
    
    func saveText() {
        UserDefaults.standard.set(text, forKey: "kmText")
    }
    
    func setSelected(_ killmail: ZKillmailModel) {
        self.selectedKillmail = killmail
    }
    
    func saveZKillModels(data: [ZKillResponseData]) async {
        let dbManager = await DataManager.shared.dbManager!
        
        let models = data.map { ZKillmailModel(data: $0)}
        try? await models.create(on: dbManager.database)
    }
    
    func fetchInfo() {
        Task {
            guard let selectedKillmail = selectedKillmail else {
                return
            }
            
            guard let result = await DataManager.shared.fetchKillmailInfo(
                killmailId: selectedKillmail.killmailId,
                killmailHash: selectedKillmail.hash
            ) else {
                return
            }
            
            do  {
                let model = ESIKillmailModel(data: result)
                try await model.save(on: DataManager.shared.dbManager!.database).get()
                await getESIModels()
            } catch let err {
                print("save esi km error \(err)")
            }
        }
    }
    
    func fetchESIKillmails(for objects: [(Int64, String)]) async {
        print("fetchESIKillmails for \(objects.count) objects")
        let result = await withTaskGroup(
            of: EveKmData?.self,
            returning: [EveKmData].self
        ) { taskGroup in
            var returnValues: [EveKmData] = []
            for (killmailId, killmailHash) in objects {
                taskGroup.addTask {
                    await self.fetchESIKillmail(
                        killmailId: killmailId,
                        killmailHash: killmailHash
                    )
                }
            }
            
            for await result in taskGroup {
                guard let result = result else { continue }
                returnValues.append(result)
            }
            
            return returnValues
        }
        
        print("got \(result.count) results")
        
        let models = result.map { ESIKillmailModel(data: $0)}
        
        do {
            try await models.create(on: DataManager.shared.dbManager!.database)
            let systemIds = models.map { $0.solarSystemId }
            
            
        } catch let err {
            print("save esi models error \(err)")
        }
    }
    
    func updateNames() async {
        let systemIds = esiModels.map{ $0.solarSystemId }
        await fetchSolarSystemInfo(for: systemIds)
        
        let characterIds = esiModels.map { killmail in
            var returnValues: [Int64] = []
            
            if let characterId = killmail.victim[0].characterId  {
                returnValues.append(characterId)
            }
            
            let attackerIds = killmail.attackers.compactMap { $0.characterId}
            returnValues.append(contentsOf: attackerIds)
            
            return returnValues
        }.flatMap { $0 }
        
        await fetchCharacterInfos(for: characterIds)
    }
    
    func removeDuplicates() async {
        let db = await DataManager.shared.dbManager!.database
        let killmails = (try? await ZKillmailModel.query(on: db)
            .all()
        ) ?? []
        
        let esiKillmails = (try? await ESIKillmailModel.query(on: db)
            .filter(\.$solarSystemId == 31002199)
            .all()
        ) ?? []
        
        let test1 = (
            try? await ZKillmailModel.query(on: db)
            .join(ESIKillmailModel.self, on: \ZKillmailModel.$killmailId == \ESIKillmailModel.$killmailId)
            .all()
        ) ?? []
        
        let test2 = (
            try? await ZKillmailModel.query(on: db)
            .join(ESIKillmailModel.self, on: \ZKillmailModel.$killmailId == \ESIKillmailModel.$killmailId)
            .join(SolarSystemModel.self, on: \SolarSystemModel.$systemID == \ESIKillmailModel.$solarSystemId)
            .all()
        ) ?? []
        
        let test3 = (
            try? await ESIKillmailModel.query(on: db)
            .filter(ESIKillmailModel.self, \.$solarSystemId == 31002199)
            .join(
                SolarSystemModel.self,
                on: \SolarSystemModel.$systemID == \ESIKillmailModel.$solarSystemId,
                method: .inner
            )
            .all()
        ) ?? []
        let test4 = (
            try? await SolarSystemModel.query(on: db)
                .all()
        ) ?? []
        
        let test5 = (
            try? await SolarSystemModel.query(on: db)
                .join(
                    ESIKillmailModel.self,
                    on: \SolarSystemModel.$systemID == \ESIKillmailModel.$solarSystemId,
                    method: .inner
                )
            .all()
        ) ?? []
        
        
            
        print("got \(killmails.count) zkillmails and \(esiKillmails.count) esikillmails")
        print("got \(test4.count) solarSystemModel")
        print("got \(test1.count) zkillmail + esiKillmail")
        print("got \(test2.count) zkillmail + esiKillmail + solarSystemModel")
        print("got \(test3.count) esiKillmail + solarSystemModel")
        print("got \(test5.count) solarSystem + esiKillmail")
        for value in test3 {
            guard let solarSystemModel = try? value.joined(SolarSystemModel.self) else { continue }
            //print("value (\(value.killmailId) \(value.solarSystemId)) (\(solarSystemModel.systemID) \(solarSystemModel.name))")
        }
        for value in test5 {
            guard let esiKillmailModel = try? value.joined(ESIKillmailModel.self) else { continue }
            //print("value1 (\(esiKillmailModel.killmailId) \(esiKillmailModel.solarSystemId)) (\(value.systemID) \(value.name))")
        }
    }
    
    func fetchSolarSystemInfo(for objects: [Int64]) async {
        /*
         Planet.query(on: database)
             .field(\.$id).field(\.$name)
             .all()
         */
        let db = await DataManager.shared.dbManager!.database
        let foo = (
            try? await SolarSystemModel.query(on: db)
            .field(\.$systemID)
            .all()
        ) ?? []
        let existingIDs = foo.map { $0.systemID }
        let filteredNewIDs = objects.filter({ value in
            return !existingIDs.contains(value)
        })
        print("getting system info for \(filteredNewIDs)")
        let results = await DataManager.shared.fetchMultipleSolarSystemInfo(
            systemIds: filteredNewIDs
        )
        
        let systemModels = results.map { SolarSystemModel(data: $0) }
        
        do {
            try await systemModels.create(on: db)
            print("created \(systemModels.count) SolarSystemModel")
        } catch let err {
            print("save system models err \(err)")
        }
    }
    
    func fetchCharacterInfos(for characterIDs: [Int64]) async {
        let db = await DataManager.shared.dbManager!.database
        let foo = (
            try? await CharacterIdentifiersModel.query(on: db)
                .all()
        ) ?? []
        
        let existingIDs = foo.map({ $0.characterID })
        let filteredNewIDs = characterIDs.filter{ value in
            return !existingIDs.contains(value)
        }
        
        let results = await DataManager.shared.fetchCharacterInfos(
            for: filteredNewIDs
        )
        
        let characterIdentifierModels = results.map { id, response in
            return CharacterIdentifiersModel(
                characterId: id,
                data: response
            )
        }
        
        do {
            try await characterIdentifierModels.create(on: db)
            print("created \(characterIdentifierModels.count) CharacterIdentifierModels")
        } catch let err {
            print("save system models err \(err)")
        }
    }
    
    
    func fetchESIKillmail(
        killmailId: Int64,
        killmailHash: String
    ) async -> EveKmData? {
        return await DataManager.shared.fetchKillmailInfo(
            killmailId: killmailId,
            killmailHash: killmailHash
        )
    }
    
    func getESIModels() async {
        let model = try? await ESIKillmailModel
            .query(on: DataManager.shared.dbManager!.database)
            .all()
            .get()
        self.esiModels = model ?? []
    }
}

struct KillmailDisplayInfo: Identifiable {
    var id: Int64 {
        return zkill.killmailId
    }
//    var id: String {
//        return UUID().uuidString
//    }
    
    let zkill: ZKillmailModel
    let esi: ESIKillmailModel
    let systemName: String
    let attackersIdentifiers: [CharacterIdentifiersModel]
    let victimIdentifier: CharacterIdentifiersModel
    let victimShipName: String
}

struct KillboardViewOLD: View {
    @State var viewModel = KillboardViewModel()
    
    let dateFormatter: DateFormatter = {
          let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//          formatter.dateStyle = .long
          return dateFormatter
      }()
    
    var body: some View {
        VStack {
            Text("KillboardView")
            VStack(alignment: .leading) {
                HStack {
                    textEditorView()
                    //esiDataView()
                    killmailDataView()
                    if let selectedKillmailInfo = viewModel.selectedKillmailInfo {
                        VStack {
                            Text("\(selectedKillmailInfo.killmail_time)")
                            Text("num attackers: \(selectedKillmailInfo.attackers.count)")
                        }
                    }
                    Spacer()
                }
                
                Spacer()
                buttons()
            }
        }
    }
    
    func esiDataView() -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 15) {
                ForEach(viewModel.esiModels, id: \.killmailId) { value in
                    VStack(alignment: .leading) {
                        Text(value.killmailTime)
                        Text("attackers: \(value.attackers.count)")
                        Text("victim: \(value.victim.first!.characterId ?? -1)")
                        Text("Isk Lost \(0)")
                    }
                }
            }
        }
    }
    
    func killmailDataView() -> some View {
        Group {
            HStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 15) {
                        ForEach(viewModel.killmailDisplayInfo, id: \.id) { value in
                            GroupBox {
                                VStack(alignment: .leading, spacing: 5) {
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack {
                                            Spacer()
                                            Text("\(ISO8601DateFormatter().date(from: value.esi.killmailTime)!, formatter: dateFormatter)")
                                        }
                                        //Text("zkill: \(value.zkill.killmailId) ESI: \(value.esi.killmailId)")
                                        Text("location: \(value.systemName)")
                                        Text("victim: \(value.victimIdentifier.name) - \(value.victimShipName)")
                                        Text("attackers: \(value.esi.attackers.count)")
                                        VStack(alignment: .leading) {
                                            Text("Attackers")
                                            VStack(alignment: .leading) {
//                                                ForEach(value.attackersIdentifiers, id: \.characterID) { info in
//                                                    Text("\(info.name) \(info.characterID)")
//                                                }
                                            }.padding(.leading, 5)
                                            
                                        }
                                    }
                                    
                                    HStack {
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            label(text: "destroyed value:", value: "\(value.zkill.destroyedValue)")
                                            label(text: "dropped value:", value: "\(value.zkill.droppedValue)")
                                            label(text: "fitted value:", value: "\(value.zkill.fittedValue)")
                                        }//.frame(maxWidth: 450)
                                    }
                                   
                                }
                            }
                        }
                    }
                }//.frame(idealWidth: 400)
                Spacer().frame(maxWidth: .infinity)
            }
        }
    }
    
    func label(text: String, value: String) -> some View {
        HStack {
            Text(text)
            Spacer()
            Text(value)
        }
    }

    
    func textEditorView() -> some View {
        VStack(alignment: .leading) {
            TextEditor(text: $viewModel.text)
                .frame(maxWidth: 250)
            
            HStack {
                Button(action: {
                    viewModel.loadText()
                }, label: {
                    Text("load")
                })
                
                Button(action: {
                    viewModel.saveText()
                }, label: {
                    Text("save")
                })
                
                Button(action: {
                    viewModel.processTextInput()
                }, label: {
                    Text("process")
                })
                
                Button(action: {
                    Task {
                        await viewModel.updateNames()
                    }
                }, label: {
                    Text("update name")
                })
                Button(action: {
                    Task {
                        await viewModel.removeDuplicates()
                    }
                }, label: {
                    Text("remove duplicates")
                })
            }
           
        }.padding()
        
    }
    
    func responseDataView() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                ForEach(viewModel.responseData, id: \.killmailId) { value in
                    VStack(alignment: .leading) {
                        Text("KM ID \(value.killmailId)")
                        Text("\(value.fittedValue)")
                        Text("\(value.locationId)")
                    }
                }
            }
        }

    }
    
    func filters() -> some View {
        VStack {
            
        }
    }
    
    func buttons() -> some View {
        HStack {
            if viewModel.selectedKillmail != nil {
                Button(action: {
                    viewModel.fetchInfo()
                }, label: {
                    Text("Fetch Killboard")
                })
            }
  
        }
    }
}

#Preview {
    KillboardView()
}
