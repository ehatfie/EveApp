//
//  DataFetcher.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/19/23.
//

import Foundation
import TestPackage1
/*
 
 open class SwaggerClientAPI {
     public static var basePath = "https://esi.evetech.net/"
     public static var credential: URLCredential?
     public static var customHeaders: [String:String] = [:]
     public static var requestBuilderFactory: RequestBuilderFactory = AlamofireRequestBuilderFactory()
 }

 */

class DataFetcher {
    init() {
       // self.credential = URLCredential(
        
    }
    func test() {
        
        UniverseAPI.getUniverseCategories(datasource: .tranquility, ifNoneMatch: nil, completion: { result, error  in
            
            
        })
    }
}
