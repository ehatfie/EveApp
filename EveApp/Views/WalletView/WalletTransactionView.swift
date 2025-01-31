//
//  WalletTransactionView.swift
//  EveApp
//
//  Created by Erik Hatfield on 1/18/25.
//

import SwiftUI
import ModelLibrary

struct WalletTransactionIdentifiable: Identifiable {
    var id: AnyHashable {
        transaction.transactionId
    }

    let transaction: CharacterWalletTransactionModel
}

struct WalletJournalEntryIdentifiable: Identifiable {
    var id: AnyHashable {
        entry.journalId
    }

    let entry: CharacterWalletJournalEntryModel
}

struct WalletTransactionView: View {
    let walletTransactions: [WalletTransactionIdentifiable]
    let journalEntries: [WalletJournalInfoDisplayable]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            VStack(alignment: .leading) {
                Text("Transactions")
                ForEach(walletTransactions) { transaction in
                    HStack {
                        Text("\(transaction.transaction.date)")
                        Text("\(transaction.transaction.typeId)")
                        Text("\(transaction.transaction.quantity)")
                        Text("\(transaction.transaction.transactionId)")
                        Text("\(transaction.transaction.journalRefId)")
                        Text(String(format: "%.2f", transaction.transaction.unitPrice))
                    }
                }
            }
            ScrollView {
                Text("Journal Entries")

                Grid(alignment: .leading, verticalSpacing: 10) {
                    GridRow(alignment: .top) {
                        Group {
                            Text("Date")
                            Text("Amount")
                            Text("FirstPersonID")
                            Text("SecondPersonID")
                            Text("context ID")
                            Text("context ID Type")
                            Text("RefType")
                            Text("Balance")
                            Text("Description")
                        }
                        .font(.subheadline)
                    }
                    
                    ForEach(journalEntries) { entry in
                        GridRow(alignment: .bottom) {
                            //HStack {
                            Text("\(entry.date.formatted(date: .numeric, time: .shortened))")
                            Text(String(format: "%.2f", entry.amount ?? 0.0).toCurrencyFormat())
                            Text(entry.firstPerson)
                            Text(entry.secondPerson)
                            Text(entry.contextId)
                            Text(entry.contextType)
                            Text(entry.refType)
                            Text(entry.balance)
                            Text(entry.description)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    WalletTransactionView(
        walletTransactions: [],
        journalEntries: []
    )
}

extension String{
     func toCurrencyFormat() -> String {
        if let doubleValue = Double(self){
           let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? ""
        } else {
            print("")
        }
    return ""
  }
}
