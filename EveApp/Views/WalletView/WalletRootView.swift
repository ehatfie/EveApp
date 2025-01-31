//
//  WalletRootView.swift
//  EveApp
//
//  Created by Erik Hatfield on 1/17/25.
//

import SwiftUI
import FluentKit
import ModelLibrary

struct WalletModelDisplayable: Identifiable {
    var id: AnyHashable {
        walletModel.id ?? UUID()
    }
    
    let characterModel: CharacterDataModel
    let walletModel: CharacterWalletModel
    
    init(
        characterModel: CharacterDataModel,
        walletModel: CharacterWalletModel
    ) {
        self.characterModel = characterModel
        self.walletModel = walletModel
    }
}

@Observable class WalletRootViewModel {
    let dbManager: DBManager
    var characterWallets: [WalletModelDisplayable] = []
    var characterWallet: WalletModelDisplayable?
    
    init (dbManager: DBManager) {
        self.dbManager = dbManager
        loadData()
    }
    
    func loadData() {
        Task {
            do {
                let wallets = try await dbManager.getWallets()
                print("got \(wallets.count) wallets")
                let foo = try wallets.compactMap { value in
                    return try value.$characterDataModel
                        .get(on: dbManager.database)
                        .map { $0 }
                        .wait()
                }
                
                print("got character models count: \(foo.count)")
                
                let result: [WalletModelDisplayable] = wallets.compactMap { wallet -> WalletModelDisplayable? in
                    guard let characterDataModel = try? wallet
                        .$characterDataModel
                        .get(on: dbManager.database)
                        .wait(),
                        let _ = try? characterDataModel.$publicData.get(on: dbManager.database).wait()
                    else {
                        return nil
                    }
                    
                    return WalletModelDisplayable(characterModel: characterDataModel, walletModel: wallet)
                }
                //let result = makeJournalInfoDisplayable(from: wallets.flatMap { $0.journalEntries })
                self.characterWallets = result
                
                let foo1 = result.compactMap { $0.walletModel.$journalEntries.value }.flatMap { $0 }
                await DataManager.shared.processWalletJournalEntries(foo1)
                
            } catch let error {
                print("get wallet error \(error)")
            }

        }
    }
    
    func updateWallets() {
        Task {
            await DataManager.shared.updateAllCharacterWallets()
        }
    }
    
    func processJournalEntries() {
        print("process journal entries")
        Task {
//            guard let wallet = characterWallets.first else {
//                print("no wallets")
//                return
//            }
            let wallet = characterWallets[0]
            await DataManager.shared.processWalletJournalEntries(wallet.walletModel.journalEntries)
            //await DataManager.shared.updateAllCharacterWallets()
        }
    }
    
    func updateWallet(for characterId: String) {
        Task {
            await DataManager.shared.updateCharacterWallet(characterId: characterId)
        }
    }
    
    func updateWalletBalance(for characterId: String) {
        Task {
            await DataManager.shared.updateCharacterWalletBalance(characterId: characterId)
        }
    }
    
    func updateWalletJournal(for characterId: String) {
        Task {
            await DataManager.shared.updateCharacterWalletJournal(characterId: characterId)
        }
    }
    
    func updateWalletTransactions(for characterId: String) {
        Task {
            await DataManager.shared.updateCharacterWalletTransactions(characterId: characterId)
        }
    }
    
    func didSelect(_ wallet: WalletModelDisplayable) {
        characterWallet = wallet
    }
}

struct WalletRootView: View {
    @State var viewModel: WalletRootViewModel
    
    init(dbManager: DBManager) {
        self.viewModel = WalletRootViewModel(dbManager: dbManager)
    }
    
    var body: some View {
        VStack {
            Text("Wallet Root View")
            
            HStack(spacing: 10) {
                ForEach(viewModel.characterWallets) { walletModel in
                    VStack {
                        GroupBox {
                            VStack(alignment: .leading, spacing: 5) {
                                if let publicData = walletModel.characterModel.publicData {
                                    Text("Name: \(publicData.name)")
                                } else {
                                    Text("CharacterID: \(walletModel.characterModel.characterId)")
                                }
                                Text("Balance: \((walletModel.walletModel.balance ?? 0.0), specifier: "%.2f")")
                                Text("Journal Entries: \(walletModel.walletModel.journalEntries.count)")
                                Text("Transactions: \(walletModel.walletModel.transactions.count)")
                                
                                Button(action: {
                                    viewModel.updateWallet(for: walletModel.characterModel.characterId)
                                }) {
                                    Text("Update wallet")
                                }
                                
                                Button(action: {
                                    viewModel.updateWalletBalance(for: walletModel.characterModel.characterId)
                                }) {
                                    Text("Update Wallet Balance")
                                }
                                
                                Button(action: {
                                    viewModel.updateWalletJournal(for: walletModel.characterModel.characterId)
                                }) {
                                    Text("Update Wallet Journal")
                                }
                                
                                Button(action: {
                                    viewModel.updateWalletTransactions(for: walletModel.characterModel.characterId)
                                }) {
                                    Text("Update Wallet Transactions")
                                }
                            }
                        }
                        .onTapGesture {
                            self.viewModel.didSelect(walletModel)
                        }
                        .border(.black)
                    }
                }
            }
            
            if let walletModel = viewModel.characterWallet {
                WalletTransactionView(
                    walletTransactions: walletModel.walletModel.transactions
                        .map {
                            WalletTransactionIdentifiable(
                                transaction: $0
                            )
                        },
                    journalEntries: viewModel.makeJournalInfoDisplayable(from: walletModel.walletModel.journalEntries)
                )
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    viewModel.updateWallets()
                }) {
                    Text("Update all wallets")
                }
                Button(action: {
                    viewModel.processJournalEntries()
                }) {
                    Text("Process journal entries")
                }
            }
        }
    }
}

#Preview {
    WalletRootView(dbManager: DBManager())
}



struct WalletJournalInfoDisplayable: Identifiable {
    var id: Int64
    var date: Date
    var amount: Double?
    var firstPerson: String
    var secondPerson: String
    var contextId: String
    var contextType: String
    var refType: String
    var balance: String
    var description: String
}

extension WalletRootViewModel {
    
    func makeJournalInfoDisplayable(from data: [CharacterWalletJournalEntryModel]) -> [WalletJournalInfoDisplayable] {
        print("makeJournalInfoDisplayable from \(data.count) entries")
        var returnValues: [WalletJournalInfoDisplayable] = []
        
        let values = data.compactMap { entry -> WalletJournalInfoDisplayable? in
            let refType = entry.refType
            guard let refTypeEnum = RefType(rawValue: refType) else {
                return nil
            }
            let firstParty: String
            let secondParty: String
            
            guard let firstPartyId = entry.firstPartyId,
                  let secondPartyId = entry.secondPartyId else { return nil }

            switch refTypeEnum {
            case .playerTrading, .playerDonation, .marketEscrow:
                if let publicData = dbManager.getCharacterPublicDataSync(by: Int64(firstPartyId)) {
                    firstParty = publicData.name
                } else {
                    firstParty = String(firstPartyId)
                }
                
                if let publicData = dbManager.getCharacterPublicDataSync(by: Int64(secondPartyId)) {
                    secondParty = publicData.name
                } else {
                    secondParty = String(secondPartyId)
                }
            case .insurance:
                firstParty = String(firstPartyId)
                if let publicData = dbManager.getCharacterPublicDataSync(by: Int64(secondPartyId)) {
                    secondParty = publicData.name
                } else {
                    secondParty = String(secondPartyId)
                }
            default :
                firstParty = String(firstPartyId)
                secondParty = String(secondPartyId)
            }
            
            let balance = String(format: "%.2f", entry.balance ?? -1.0).toCurrencyFormat()
            return WalletJournalInfoDisplayable(
                id: entry.journalId,
                date: entry.date,
                amount: entry.amount,
                firstPerson: firstParty,
                secondPerson: secondParty,
                contextId: String(entry.contextId ?? 0),
                contextType: entry.contextIdType ?? "",
                refType: refType,
                balance: balance,
                description: entry.entryDescription
            )
        }
        returnValues = values
        return returnValues
    }
    
}

/*
 
 var characterIds: Set<Int64> = []
 
 for entry in entries {
   let refType = entry.refType
   guard let refTypeEnum = RefType(rawValue: refType) else { continue }
   
   print("got refTypeEnum \(refTypeEnum)")
   switch refTypeEnum {
   case .playerTrading, .playerDonation:
     guard let firstPartyId = entry.firstPartyId,
           let secondPartyId = entry.secondPartyId else { continue }
     characterIds.insert(Int64(firstPartyId))
     characterIds.insert(Int64(secondPartyId))
     
   default: break
   }
 */
