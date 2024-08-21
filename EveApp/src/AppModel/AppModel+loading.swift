//
//  AppModel+loading.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Foundation
import Yams
import TestPackage1

enum YamlFiles: String {
  case categoryIDs = "categoryIDs"
  case groupIDs = "groupIDs"
  case typeIDs = "typeIDs"
  case dogmaAttrbutes = "dogmaAttributes"
  case dogmaEffects = "dogmaEffects"
  case typeDogma = "typeDogma"
  case dogmaAttributeCategories = "dogmaAttributeCategories"
  case typeDogmaInfo = "typeDogmaInfo"
  case typeMaterials = "typeMaterials"
  case blueprints = "blueprints"
  case races = "races"
}


class ThingCategory {
    let id: Int64 = 0
    let name: String = ""
    let published: Bool = true
}



//struct ThingName: Codable {
//    let de: String?
//    let en: String?
//    let es: String?
//    let fr: String?
//    let ja: String?
//    let ru: String?
//    let zh: String?
//    
//    init(name: String) {
//        self.init(en: name)
//    }
//    
//    internal init(
//        de: String? = nil,
//        en: String? = nil,
//        es: String? = nil,
//        fr: String? = nil,
//        ja: String? = nil,
//        ru: String? = nil,
//        zh: String? = nil
//    ) {
//        self.de = de
//        self.en = en
//        self.es = es
//        self.fr = fr
//        self.ja = ja
//        self.ru = ru
//        self.zh = zh
//    }
//}
