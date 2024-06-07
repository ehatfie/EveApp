//
//  ESIScopes.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/14/24.
//

import Foundation

enum ESIScopes: String {
    static var root = "esi-skills."
    static var version = ".v1"
    
    case skillQueue = "esi-skills.read_skillqueue.v1"
    case assets = "esi-assets.read_assets.v1"
    case structureInfo = "esi-universe.read_structures.v1" //esi-universe.read_structures.v1
}
