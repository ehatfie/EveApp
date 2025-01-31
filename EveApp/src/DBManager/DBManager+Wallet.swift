//
//  DBManager+Wallet.swift
//  EveApp
//
//  Created by Erik Hatfield on 1/17/25.
//
import Foundation
import Yams
import FluentKit
import ModelLibrary


extension DBManager {
    
    func getWallets() async throws -> [CharacterWalletModel] {
        let characterWalletModels = try await CharacterWalletModel.query(on: self.database)
            .with(\.$characterDataModel)
            .with(\.$journalEntries)
            .with(\.$transactions)
            .all()
        print("++ got \(characterWalletModels.count) character wallets")
        return characterWalletModels
    }
    
}
