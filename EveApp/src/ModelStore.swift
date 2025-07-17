//
//  ModelStore.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/3/25.
//
import Foundation
import SwiftUI

import ModelLibrary

/// All `MailCore` work is funnelled through this executor.
@globalActor
final actor ModelCoreActor {
    static let shared = ModelCoreActor()
}


/// Owns canonical mailbox state; synchronous members run on `MailCoreActor`.
@ModelCoreActor
final class ModelCore {

    /// Dependency on the infrastructure actor.
    //private let sync: SyncEngine

    /// Mutable mailbox cache (actor-protected via the global actor).
    //private var inbox = [Email]()

    /// Non-isolated constructor so MainActor contexts can instantiate directly.
//    nonisolated init(sync: SyncEngine = .shared) {
//        self.sync = sync
//    }
    nonisolated init() {
    }

    /// Return a defensive copy of the current inbox.
    func snapshot() -> [String] {
        //inbox
        return []
    }

    /// Replace local cache with server data.
    func refresh() async throws {
        //inbox = try await sync.fetchInbox()
    }

    /// Toggle read flag locally and persist remotely.
    func markAsRead(_ id: UUID) async {
//        guard let idx = inbox.firstIndex(where: { $0.id == id }) else { return }
//        inbox[idx].isRead = true
//        await sync.markRead(id)
    }

    /// Insert messages that arrived via push notification.
    func insert(_ new: [String]) {
        //inbox.insert(contentsOf: new, at: 0)
    }
}

@MainActor
@Observable
final class ModelStore {
    /// Latest view-layer copy of the inbox.
    //var inbox: [Email] = []

    /// Derived badge counter.
    var unreadCount: Int {
        //inbox.filter { !$0.isRead }.count
        return 0
    }

    /// Bridge to the global-actor-isolated engine.
    private let core: ModelCore

    /// Default initialiser spins up its own core.
    init(core: ModelCore = .init()) {
        self.core = core
    }

    /// Pull data and publish it to SwiftUI.
    func refresh() async {
        do {
            //inbox = await core.snapshot()        // quick optimistic draw
            try await core.refresh()             // network call
            //inbox = await core.snapshot()        // final copy
        } catch {
            print("Refresh failed:", error)
        }
    }

    /// Insert new messages (e.g. from APNs).
    func insert(_ new: [String]) async {
        await core.insert(new)
        //inbox = await core.snapshot()
    }
}
