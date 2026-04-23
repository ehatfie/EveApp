//
//  ESIKillmailDisplayableView.swift
//  EveSwiftData
//
//  Created by Erik Hatfield on 7/20/25.
//

import ModelLibrary
import SwiftUI

struct ESIKillmailDisplayableView: View {
  let killmail: ESIKillmailDisplayInfo

  let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")  // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    //          formatter.dateStyle = .long
    return dateFormatter
  }()

  var body: some View {
    GroupBox {
      VStack(alignment: .leading, spacing: 10) {
        HStack {
          Text("id \(killmail.esi.killmailId)")
          
          if let date = ISO8601DateFormatter().date(
            from: killmail.esi.killmailTime
          ) {
            Text("\(date, formatter: dateFormatter)")
            //Text("Time \(dateFormatter.string(from: date))")
          } else {
            Text("Weird Time \(killmail.esi.killmailTime)")
          }
        }
        
        VStack(alignment: .leading, spacing: 20) {
          GroupBox {
            victimSection()
              .padding()
          }
          GroupBox {
            attackerSection()
              .padding()
          }
          
        }
        
      }.padding()
    }
  }

  @ViewBuilder
  func victimSection() -> some View {
    KillmailVictimView(
      victim: killmail.victimInfo,
      system: killmail.systemName
    )
  }

  @ViewBuilder
  func attackerSection() -> some View {
    VStack(alignment: .leading, spacing: 15) {
      Text("Attackers").font(.title2)
      
      VStack(alignment: .leading, spacing: 10) {
        ForEach(killmail.attackersIdentifiers) { attacker in
          KillmailAttackerView(attacker: attacker)
            
        }
      }
    }
  }

}

#Preview {
  ESIKillmailDisplayableView(
    killmail: ESIKillmailDisplayInfo(
      esi: ESIKillmailModel(
        attackers: [],
        killmailId: 1,
        killmailTime: "2025-06-26T02:07-36Z",
        solarSystemId: 1,
        victim: ESIKmVictim(allianceId: 0, damageTaken: 1000, items: [])
      ),
      systemName: IdentifiedString(id: 12, value: "system_name"),
      attackersIdentifiers: [
        .mockAttacker
      ],
      victimInfo: .mockVictim,
      victimShipName: .thorax
    )
  )
}

extension KillmailAttackerInfo {
  static var mockAttacker: KillmailAttackerInfo {
    KillmailAttackerInfo(
      killmailId: 1,
      character: .someName,
      corporation: .corporation,
      alliance: .alliance,
      damageDone: 100,
      finalBlow: true,
      ship: .vexor,
      weapon: .hobgoblin
    )
  }
}

extension KillmailVictimInfo {
  static var mockVictim: KillmailVictimInfo {
    KillmailVictimInfo(
      character: .victimName,
      corporation: .victimCorporation,
      alliance: .victimAlliance,
      damageTaken: 100,
      ship: .thorax
    )
  }
}

extension IdentifiedString {
  static var victimName = IdentifiedString(
    id: 22,
    value: "Victim Name"
  )
  static var victimCorporation = IdentifiedString(
    id: 33,
    value: "Victim Corp Name"
  )
  static var victimAlliance = IdentifiedString(
    id: 384,
    value: "Victim Alliance Name"
  )

  static var someName = IdentifiedString(id: 2, value: "Some Name")
  static var corporation = IdentifiedString(id: 3, value: "Corp Name")
  static var alliance = IdentifiedString(id: 38, value: "Alliance Name")

  static var vexor = IdentifiedString(id: 4, value: "Vexor")
  static var thorax = IdentifiedString(id: 44, value: "Thorax")

  static var hobgoblin = IdentifiedString(id: 5, value: "Hobgoblin II")
}
