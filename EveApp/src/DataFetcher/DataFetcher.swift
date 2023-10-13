//
//  DataFetcher.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/19/23.
//

import Foundation


class DataFetcher {
    func test() {
        
        UniverseAPI.getUniverseCategories(datasource: .tranquility, ifNoneMatch: nil, completion: { result, error  in
            
            
        })
    }
}
