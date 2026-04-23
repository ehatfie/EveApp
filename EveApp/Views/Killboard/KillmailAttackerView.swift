//
//  KillmailAttackerView.swift
//  EveSwiftData
//
//  Created by Erik Hatfield on 7/20/25.
//

import SwiftUI

struct KillmailAttackerView: View {
  let attacker: KillmailAttackerInfo

  var body: some View {
    HStack(alignment: .top) {
//      Rectangle()
//        .frame(width: 50, height: 50)
      VStack(alignment: .leading) {
        if let character = attacker.character {
          Text(character.value)
            .underline(attacker.finalBlow, pattern: .solid)
            //.font(.title3)
        }
        
        if let corporation = attacker.corporation {
          Text(corporation.value)
            .font(.caption)
            //.font(.headline)
        }
      }
      VStack(alignment: .trailing, spacing: 20) {
        VStack(alignment: .leading) {
          Text(attacker.ship.value)
          
          if let weapon = attacker.weapon {
            Text(weapon.value)
              .font(.caption)
          }
        }
      }
    Text("\(attacker.damageDone)")
        .font(.headline)
    }.fixedSize()
  }
}

#Preview {
  KillmailAttackerView(
    attacker: .init(
        killmailId: 0,
        character: IdentifiedString(id: 0, value: "Character Name"),
        corporation: IdentifiedString(id: 1, value: "Corporation Name"),
        alliance: IdentifiedString(id: 2, value: "Alliance Name"),
        damageDone: 100,
        finalBlow: true,
        ship: IdentifiedString(id: 3, value: "Name"),
        weapon: IdentifiedString(id: 4, value: "Weapon")
    )
  ).padding()
}
