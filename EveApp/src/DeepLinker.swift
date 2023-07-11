//
//  DeepLinker.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/7/23.
//

import Foundation

class Deeplinker {
    // possibly add string values?
    enum Deeplink: Equatable {
        case home
        case accessKey(value: String)
        case details(reference: String)
        case unknown
    }
    
    func manage(url: URL) -> Deeplink? {
        print("URL \(url.scheme)")
        print("Path \(url.path(percentEncoded: true))")
        
        guard let query = url.query else { return nil }
        let components = query.split(separator: "&").flatMap { $0.split(separator: "=") }
        
        print("Components \(components)")
        if components[0] == "code" {
            print("got auth code")
            let value = String(components[1])
            
            return .accessKey(value: value)
        }
        
//        guard let idIndex = components.firstIndex(of: Substring(URL.appReferenceQueryName)) else { return nil }
        //guard idIndex + 1 < components.count else { return nil }
        
        return .unknown//.details(reference: "TEST")
        //return .details(reference: String(components[idIndex.advanced(by: 1)]))
    }
}
