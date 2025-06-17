//
//  DM+CharacterFetching.swift
//  EveApp
//
//  Created by Erik Hatfield on 4/4/25.
//


import Foundation
import Fluent
import FluentSQLiteDriver
import ModelLibrary

// MARK: - Character fetching

public struct GetCharactersSearch: Codable {

    /** agent array */
    public var agent: [Int]?
    /** alliance array */
    public var alliance: [Int]?
    /** character array */
    public var character: [Int]?
    /** constellation array */
    public var constellation: [Int]?
    /** corporation array */
    public var corporation: [Int]?
    /** faction array */
    public var faction: [Int]?
    /** inventory_type array */
    public var inventoryType: [Int]?
    /** region array */
    public var region: [Int]?
    /** solar_system array */
    public var solarSystem: [Int]?
    /** station array */
    public var station: [Int]?
    /** structure array */
    public var structure: [Int64]?

    public init(agent: [Int]? = nil, alliance: [Int]? = nil, character: [Int]? = nil, constellation: [Int]? = nil, corporation: [Int]? = nil, faction: [Int]? = nil, inventoryType: [Int]? = nil, region: [Int]? = nil, solarSystem: [Int]? = nil, station: [Int]? = nil, structure: [Int64]? = nil) {
        self.agent = agent
        self.alliance = alliance
        self.character = character
        self.constellation = constellation
        self.corporation = corporation
        self.faction = faction
        self.inventoryType = inventoryType
        self.region = region
        self.solarSystem = solarSystem
        self.station = station
        self.structure = structure
    }

    public enum CodingKeys: String, CodingKey {
        case agent
        case alliance
        case character
        case constellation
        case corporation
        case faction
        case inventoryType = "inventory_type"
        case region
        case solarSystem = "solar_system"
        case station
        case structure
    }

}

public struct ESISearchResponse: Codable {

    /** agent array */
    public var agent: [Int]?
    /** alliance array */
    public var alliance: [Int]?
    /** character array */
    public var character: [Int]?
    /** constellation array */
    public var constellation: [Int]?
    /** corporation array */
    public var corporation: [Int]?
    /** faction array */
    public var faction: [Int]?
    /** inventory_type array */
    public var inventoryType: [Int]?
    /** region array */
    public var region: [Int]?
    /** solar_system array */
    public var solarSystem: [Int]?
    /** station array */
    public var station: [Int]?
    /** structure array */
    public var structure: [Int64]?

    public init(agent: [Int]? = nil, alliance: [Int]? = nil, character: [Int]? = nil, constellation: [Int]? = nil, corporation: [Int]? = nil, faction: [Int]? = nil, inventoryType: [Int]? = nil, region: [Int]? = nil, solarSystem: [Int]? = nil, station: [Int]? = nil, structure: [Int64]? = nil) {
        self.agent = agent
        self.alliance = alliance
        self.character = character
        self.constellation = constellation
        self.corporation = corporation
        self.faction = faction
        self.inventoryType = inventoryType
        self.region = region
        self.solarSystem = solarSystem
        self.station = station
        self.structure = structure
    }

    public enum CodingKeys: String, CodingKey {
        case agent
        case alliance
        case character
        case constellation
        case corporation
        case faction
        case inventoryType = "inventory_type"
        case region
        case solarSystem = "solar_system"
        case station
        case structure
    }

}

extension DataManager {
    func searchCharacter(named name: String, strict: Bool = true) async -> GetCharactersSearch? {
        guard let authModel = await getAuthModel() else { return nil}
        
        let dataEndpoint = "/characters/\(authModel.characterId)/search/"
        let endpoint = "https://esi.evetech.net/latest"
        guard let accessTokenData = decodeAccessToken(data: authModel.accessToken) else {
          return nil
        }
        let urlString = endpoint + dataEndpoint
        //let url = URL(string: urlString)!
        var url = URLComponents(string: urlString)!
        
        url.queryItems = APIHelper.mapValuesToQueryItems([
            "categories": ["character"],
            "datasource": "tranquility",
            "language": "en-us",
            "search": name,
            "strict": strict,
            "token": authModel.accessToken
        ])
        var urlRequest = URLRequest(url: url.url!)
        
        let headers: [String:String] = [
          "Authorization": "Bearer \(authModel.accessToken)"
        ]
        
        //urlRequest.allHTTPHeaderFields = headers
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            print("Data string: \(String(data: data, encoding: .utf8))")
            let response = try JSONDecoder()
                .decode(GetCharactersSearch.self, from: data)
            return response
            print("get characters search response \(response)")
        } catch let err {
          print("async api call error \(err)")
            return nil
        }
    }
    
    func searchStation(stationId: String, strict: Bool = true) async -> ESISearchResponse? {
        return await searchSomething(searchText: stationId, categories: ["station"])
    }
    
    func searchSomething(searchText: String, categories: [String], strict: Bool = true) async -> ESISearchResponse? {
        guard let authModel = await getAuthModel() else { return nil}
        
        let dataEndpoint = "/characters/\(authModel.characterId)/search/"
        let endpoint = "https://esi.evetech.net/latest"
        guard let accessTokenData = decodeAccessToken(data: authModel.accessToken) else {
          return nil
        }
        let urlString = endpoint + dataEndpoint
        //let url = URL(string: urlString)!
        var url = URLComponents(string: urlString)!
        
        url.queryItems = APIHelper.mapValuesToQueryItems([
            "categories": categories,
            "datasource": "tranquility",
            "language": "en-us",
            "search": searchText,
            "strict": strict,
            "token": authModel.accessToken
        ])
        var urlRequest = URLRequest(url: url.url!)
        
        let headers: [String:String] = [
          "Authorization": "Bearer \(authModel.accessToken)"
        ]
        
        //urlRequest.allHTTPHeaderFields = headers
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            print("Data string: \(String(data: data, encoding: .utf8))")
            let response = try JSONDecoder()
                .decode(ESISearchResponse.self, from: data)
            return response
            print("get ESI search response \(response)")
        } catch let err {
          print("async api call error \(err)")
            return nil
        }
    }
}
