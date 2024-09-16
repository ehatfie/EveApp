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
            await self.loadDisplayData()
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
        let killmails = (try? await ZKillmailModel.query(on: dbManager.database)
            .join(ESIKillmailModel.self, on: \ZKillmailModel.$killmailId == \ESIKillmailModel.$killmailId)
            .all()
            .get()) ?? []
        
        let displayInfo = killmails.compactMap { zKillmail -> KillmailDisplayInfo? in
            guard let esiKillmail = try? zKillmail.joined(ESIKillmailModel.self) else {
                return nil
            }
            return KillmailDisplayInfo(zkill: zKillmail, esi: esiKillmail)
        }
        print("got killmails \(killmails.count)")
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
        } catch let err {
            print("save esi models error \(err)")
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
    
    let zkill: ZKillmailModel
    let esi: ESIKillmailModel
}

struct KillboardView: View {
    @State var viewModel = KillboardViewModel()
    
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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 15) {
                ForEach(viewModel.killmailDisplayInfo, id: \.id) { value in
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(value.id)")
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(value.esi.killmailTime)")
                                Text("location: \(value.esi.solarSystemId)")
                            }
                            Text("victim: \(value.esi.victim.first!.characterId ?? -1)")
                            Text("attackers: \(value.esi.attackers.count)")
                        }
                        
                        VStack(alignment: .leading) {
                            label(text: "destroyed value:", value: "\(value.zkill.destroyedValue)")
                            label(text: "dropped value:", value: "\(value.zkill.droppedValue)")
                            label(text: "fitted value:", value: "\(value.zkill.fittedValue)")
                        }.frame(maxWidth: 250)
                    }
                }
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
