//
// KillmailsAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire


@MainActor open class KillmailsAPI {
    /**
     * enum for parameter datasource
     */
    public enum Datasource_getCharactersCharacterIdKillmailsRecent: String { 
        case tranquility = "tranquility"
    }

    /**
     Get a character's recent kills and losses

     - parameter characterId: (path) An EVE character ID 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter page: (query) Which page of results to return (optional, default to 1)
     - parameter token: (query) Access token to use if unable to set a header (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    @MainActor open class func getCharactersCharacterIdKillmailsRecent(characterId: Int, datasource: Datasource_getCharactersCharacterIdKillmailsRecent? = nil, ifNoneMatch: String? = nil, page: Int? = nil, token: String? = nil, completion: @escaping ((_ data: [GetCharactersCharacterIdKillmailsRecent200Ok]?,_ error: Error?) -> Void)) {
        getCharactersCharacterIdKillmailsRecentWithRequestBuilder(characterId: characterId, datasource: datasource, ifNoneMatch: ifNoneMatch, page: page, token: token).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get a character's recent kills and losses
     - GET /v1/characters/{character_id}/killmails/recent/

     - OAuth:
       - type: oauth2
       - name: evesso
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String), X-Pages(Int)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String), X-Pages(Int)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String), X-Pages(Int)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String), X-Pages(Int)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String), X-Pages(Int)]
     - examples: [{contentType=application/json, example=[ {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
} ]}]
     - parameter characterId: (path) An EVE character ID 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter page: (query) Which page of results to return (optional, default to 1)
     - parameter token: (query) Access token to use if unable to set a header (optional)

     - returns: RequestBuilder<[GetCharactersCharacterIdKillmailsRecent200Ok]> 
     */
    @MainActor open class func getCharactersCharacterIdKillmailsRecentWithRequestBuilder(characterId: Int, datasource: Datasource_getCharactersCharacterIdKillmailsRecent? = nil, ifNoneMatch: String? = nil, page: Int? = nil, token: String? = nil) -> RequestBuilder<[GetCharactersCharacterIdKillmailsRecent200Ok]> {
        var path = "/v1/characters/{character_id}/killmails/recent/"
        let characterIdPreEscape = "\(characterId)"
        let characterIdPostEscape = characterIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{character_id}", with: characterIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
                        "datasource": datasource?.rawValue, 
                        "page": page?.encodeToJSON(), 
                        "token": token
        ])
        let nillableHeaders: [String: Any?] = [
                        "If-None-Match": ifNoneMatch
        ]
        let headerParameters = APIHelper.rejectNilHeaders(nillableHeaders)

        let requestBuilder: RequestBuilder<[GetCharactersCharacterIdKillmailsRecent200Ok]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
    /**
     * enum for parameter datasource
     */
    public enum Datasource_getCorporationsCorporationIdKillmailsRecent: String { 
        case tranquility = "tranquility"
    }

    /**
     Get a corporation's recent kills and losses

     - parameter corporationId: (path) An EVE corporation ID 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter page: (query) Which page of results to return (optional, default to 1)
     - parameter token: (query) Access token to use if unable to set a header (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    @MainActor open class func getCorporationsCorporationIdKillmailsRecent(corporationId: Int, datasource: Datasource_getCorporationsCorporationIdKillmailsRecent? = nil, ifNoneMatch: String? = nil, page: Int? = nil, token: String? = nil, completion: @escaping ((_ data: [GetCorporationsCorporationIdKillmailsRecent200Ok]?,_ error: Error?) -> Void)) {
        getCorporationsCorporationIdKillmailsRecentWithRequestBuilder(corporationId: corporationId, datasource: datasource, ifNoneMatch: ifNoneMatch, page: page, token: token).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get a corporation's recent kills and losses
     - GET /v1/corporations/{corporation_id}/killmails/recent/

     - OAuth:
       - type: oauth2
       - name: evesso
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String), X-Pages(Int)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String), X-Pages(Int)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String), X-Pages(Int)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String), X-Pages(Int)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String), X-Pages(Int)]
     - examples: [{contentType=application/json, example=[ {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
}, {
  "killmail_hash" : "killmail_hash",
  "killmail_id" : 0
} ]}]
     - parameter corporationId: (path) An EVE corporation ID 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter page: (query) Which page of results to return (optional, default to 1)
     - parameter token: (query) Access token to use if unable to set a header (optional)

     - returns: RequestBuilder<[GetCorporationsCorporationIdKillmailsRecent200Ok]> 
     */
    @MainActor open class func getCorporationsCorporationIdKillmailsRecentWithRequestBuilder(corporationId: Int, datasource: Datasource_getCorporationsCorporationIdKillmailsRecent? = nil, ifNoneMatch: String? = nil, page: Int? = nil, token: String? = nil) -> RequestBuilder<[GetCorporationsCorporationIdKillmailsRecent200Ok]> {
        var path = "/v1/corporations/{corporation_id}/killmails/recent/"
        let corporationIdPreEscape = "\(corporationId)"
        let corporationIdPostEscape = corporationIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{corporation_id}", with: corporationIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
                        "datasource": datasource?.rawValue, 
                        "page": page?.encodeToJSON(), 
                        "token": token
        ])
        let nillableHeaders: [String: Any?] = [
                        "If-None-Match": ifNoneMatch
        ]
        let headerParameters = APIHelper.rejectNilHeaders(nillableHeaders)

        let requestBuilder: RequestBuilder<[GetCorporationsCorporationIdKillmailsRecent200Ok]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
    /**
     * enum for parameter datasource
     */
    public enum Datasource_getKillmailsKillmailIdKillmailHash: String { 
        case tranquility = "tranquility"
    }

    /**
     Get a single killmail

     - parameter killmailHash: (path) The killmail hash for verification 
     - parameter killmailId: (path) The killmail ID to be queried 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    @MainActor open class func getKillmailsKillmailIdKillmailHash(killmailHash: String, killmailId: Int, datasource: Datasource_getKillmailsKillmailIdKillmailHash? = nil, ifNoneMatch: String? = nil, completion: @escaping ((_ data: GetKillmailsKillmailIdKillmailHashOk?,_ error: Error?) -> Void)) {
        getKillmailsKillmailIdKillmailHashWithRequestBuilder(killmailHash: killmailHash, killmailId: killmailId, datasource: datasource, ifNoneMatch: ifNoneMatch).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get a single killmail
     - GET /v1/killmails/{killmail_id}/{killmail_hash}/

     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - examples: [{contentType=application/json, example={
  "killmail_time" : "2000-01-23T04:56:07.000+00:00",
  "moon_id" : 2,
  "attackers" : [ {
    "ship_type_id" : 7,
    "alliance_id" : 0,
    "corporation_id" : 1,
    "security_status" : 2.302136,
    "weapon_type_id" : 9,
    "damage_done" : 5,
    "faction_id" : 5,
    "character_id" : 6,
    "final_blow" : true
  }, {
    "ship_type_id" : 7,
    "alliance_id" : 0,
    "corporation_id" : 1,
    "security_status" : 2.302136,
    "weapon_type_id" : 9,
    "damage_done" : 5,
    "faction_id" : 5,
    "character_id" : 6,
    "final_blow" : true
  }, {
    "ship_type_id" : 7,
    "alliance_id" : 0,
    "corporation_id" : 1,
    "security_status" : 2.302136,
    "weapon_type_id" : 9,
    "damage_done" : 5,
    "faction_id" : 5,
    "character_id" : 6,
    "final_blow" : true
  }, {
    "ship_type_id" : 7,
    "alliance_id" : 0,
    "corporation_id" : 1,
    "security_status" : 2.302136,
    "weapon_type_id" : 9,
    "damage_done" : 5,
    "faction_id" : 5,
    "character_id" : 6,
    "final_blow" : true
  }, {
    "ship_type_id" : 7,
    "alliance_id" : 0,
    "corporation_id" : 1,
    "security_status" : 2.302136,
    "weapon_type_id" : 9,
    "damage_done" : 5,
    "faction_id" : 5,
    "character_id" : 6,
    "final_blow" : true
  }, {
    "ship_type_id" : 7,
    "alliance_id" : 0,
    "corporation_id" : 1,
    "security_status" : 2.302136,
    "weapon_type_id" : 9,
    "damage_done" : 5,
    "faction_id" : 5,
    "character_id" : 6,
    "final_blow" : true
  }, {
    "ship_type_id" : 7,
    "alliance_id" : 0,
    "corporation_id" : 1,
    "security_status" : 2.302136,
    "weapon_type_id" : 9,
    "damage_done" : 5,
    "faction_id" : 5,
    "character_id" : 6,
    "final_blow" : true
  }, {
    "ship_type_id" : 7,
    "alliance_id" : 0,
    "corporation_id" : 1,
    "security_status" : 2.302136,
    "weapon_type_id" : 9,
    "damage_done" : 5,
    "faction_id" : 5,
    "character_id" : 6,
    "final_blow" : true
  }, {
    "ship_type_id" : 7,
    "alliance_id" : 0,
    "corporation_id" : 1,
    "security_status" : 2.302136,
    "weapon_type_id" : 9,
    "damage_done" : 5,
    "faction_id" : 5,
    "character_id" : 6,
    "final_blow" : true
  }, {
    "ship_type_id" : 7,
    "alliance_id" : 0,
    "corporation_id" : 1,
    "security_status" : 2.302136,
    "weapon_type_id" : 9,
    "damage_done" : 5,
    "faction_id" : 5,
    "character_id" : 6,
    "final_blow" : true
  } ],
  "solar_system_id" : 4,
  "victim" : {
    "ship_type_id" : 2,
    "alliance_id" : 7,
    "corporation_id" : 1,
    "faction_id" : 6,
    "character_id" : 1,
    "position" : {
      "x" : 3.5571952270680973,
      "y" : 6.965117697638846,
      "z" : 1.284659006116532
    },
    "damage_taken" : 1,
    "items" : [ {
      "quantity_destroyed" : 8,
      "singleton" : 6,
      "flag" : 7,
      "item_type_id" : 1,
      "quantity_dropped" : 9,
      "items" : [ {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      } ]
    }, {
      "quantity_destroyed" : 8,
      "singleton" : 6,
      "flag" : 7,
      "item_type_id" : 1,
      "quantity_dropped" : 9,
      "items" : [ {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      } ]
    }, {
      "quantity_destroyed" : 8,
      "singleton" : 6,
      "flag" : 7,
      "item_type_id" : 1,
      "quantity_dropped" : 9,
      "items" : [ {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      } ]
    }, {
      "quantity_destroyed" : 8,
      "singleton" : 6,
      "flag" : 7,
      "item_type_id" : 1,
      "quantity_dropped" : 9,
      "items" : [ {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      } ]
    }, {
      "quantity_destroyed" : 8,
      "singleton" : 6,
      "flag" : 7,
      "item_type_id" : 1,
      "quantity_dropped" : 9,
      "items" : [ {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      } ]
    }, {
      "quantity_destroyed" : 8,
      "singleton" : 6,
      "flag" : 7,
      "item_type_id" : 1,
      "quantity_dropped" : 9,
      "items" : [ {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      } ]
    }, {
      "quantity_destroyed" : 8,
      "singleton" : 6,
      "flag" : 7,
      "item_type_id" : 1,
      "quantity_dropped" : 9,
      "items" : [ {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      } ]
    }, {
      "quantity_destroyed" : 8,
      "singleton" : 6,
      "flag" : 7,
      "item_type_id" : 1,
      "quantity_dropped" : 9,
      "items" : [ {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      } ]
    }, {
      "quantity_destroyed" : 8,
      "singleton" : 6,
      "flag" : 7,
      "item_type_id" : 1,
      "quantity_dropped" : 9,
      "items" : [ {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      } ]
    }, {
      "quantity_destroyed" : 8,
      "singleton" : 6,
      "flag" : 7,
      "item_type_id" : 1,
      "quantity_dropped" : 9,
      "items" : [ {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      }, {
        "quantity_destroyed" : 9,
        "singleton" : 6,
        "flag" : 4,
        "item_type_id" : 5,
        "quantity_dropped" : 9
      } ]
    } ]
  },
  "killmail_id" : 3,
  "war_id" : 6
}}]
     - parameter killmailHash: (path) The killmail hash for verification 
     - parameter killmailId: (path) The killmail ID to be queried 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)

     - returns: RequestBuilder<GetKillmailsKillmailIdKillmailHashOk> 
     */
    @MainActor open class func getKillmailsKillmailIdKillmailHashWithRequestBuilder(killmailHash: String, killmailId: Int, datasource: Datasource_getKillmailsKillmailIdKillmailHash? = nil, ifNoneMatch: String? = nil) -> RequestBuilder<GetKillmailsKillmailIdKillmailHashOk> {
        var path = "/v1/killmails/{killmail_id}/{killmail_hash}/"
        let killmailHashPreEscape = "\(killmailHash)"
        let killmailHashPostEscape = killmailHashPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{killmail_hash}", with: killmailHashPostEscape, options: .literal, range: nil)
        let killmailIdPreEscape = "\(killmailId)"
        let killmailIdPostEscape = killmailIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{killmail_id}", with: killmailIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
                        "datasource": datasource?.rawValue
        ])
        let nillableHeaders: [String: Any?] = [
                        "If-None-Match": ifNoneMatch
        ]
        let headerParameters = APIHelper.rejectNilHeaders(nillableHeaders)

        let requestBuilder: RequestBuilder<GetKillmailsKillmailIdKillmailHashOk>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
}
