//
//  KillmailVictimView.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/20/25.
//

import SwiftUI

struct KillmailVictimView: View {
  let victim: KillmailVictimInfo
  let system: IdentifiedString

  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      Text("Victim")
        .font(.title2)
      HStack(alignment: .top) {
        VStack(alignment: .leading) {
          //Text(killmail.victimInfo.character!.value)
          if let character = victim.character {
            Text(character.value)
              .font(.title3)
          }
          //Text(killmail.victimInfo.corporation!.value)
          if let corporation = victim.corporation {
            Text(corporation.value)
              .font(.caption)
          }

        }.fixedSize(horizontal: true, vertical: false)
        VStack(alignment: .leading) {
          Text(victim.ship.value)
          Text(system.value)
          
        }
        Text("\(victim.damageTaken)")
      }
    }
  }
}

#Preview {
  KillmailVictimView(
    victim: .mockVictim,
    system: IdentifiedString(id: 2_121_221, value: "System Name")
  ).padding()
}
