//
// ClonesAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire


@MainActor open class ClonesAPI {
    /**
     * enum for parameter datasource
     */
    public enum Datasource_getCharactersCharacterIdClones: String { 
        case tranquility = "tranquility"
    }

    /**
     Get clones

     - parameter characterId: (path) An EVE character ID 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter token: (query) Access token to use if unable to set a header (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    @MainActor open class func getCharactersCharacterIdClones(characterId: Int, datasource: Datasource_getCharactersCharacterIdClones? = nil, ifNoneMatch: String? = nil, token: String? = nil, completion: @escaping ((_ data: GetCharactersCharacterIdClonesOk?,_ error: Error?) -> Void)) {
        getCharactersCharacterIdClonesWithRequestBuilder(characterId: characterId, datasource: datasource, ifNoneMatch: ifNoneMatch, token: token).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get clones
     - GET /v3/characters/{character_id}/clones/

     - OAuth:
       - type: oauth2
       - name: evesso
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - examples: [{contentType=application/json, example={
  "last_station_change_date" : "2000-01-23T04:56:07.000+00:00",
  "last_clone_jump_date" : "2000-01-23T04:56:07.000+00:00",
  "jump_clones" : [ {
    "name" : "name",
    "jump_clone_id" : 1,
    "implants" : [ 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 ],
    "location_id" : 5,
    "location_type" : "station"
  }, {
    "name" : "name",
    "jump_clone_id" : 1,
    "implants" : [ 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 ],
    "location_id" : 5,
    "location_type" : "station"
  }, {
    "name" : "name",
    "jump_clone_id" : 1,
    "implants" : [ 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 ],
    "location_id" : 5,
    "location_type" : "station"
  }, {
    "name" : "name",
    "jump_clone_id" : 1,
    "implants" : [ 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 ],
    "location_id" : 5,
    "location_type" : "station"
  }, {
    "name" : "name",
    "jump_clone_id" : 1,
    "implants" : [ 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 ],
    "location_id" : 5,
    "location_type" : "station"
  }, {
    "name" : "name",
    "jump_clone_id" : 1,
    "implants" : [ 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 ],
    "location_id" : 5,
    "location_type" : "station"
  }, {
    "name" : "name",
    "jump_clone_id" : 1,
    "implants" : [ 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 ],
    "location_id" : 5,
    "location_type" : "station"
  }, {
    "name" : "name",
    "jump_clone_id" : 1,
    "implants" : [ 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 ],
    "location_id" : 5,
    "location_type" : "station"
  }, {
    "name" : "name",
    "jump_clone_id" : 1,
    "implants" : [ 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 ],
    "location_id" : 5,
    "location_type" : "station"
  }, {
    "name" : "name",
    "jump_clone_id" : 1,
    "implants" : [ 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 ],
    "location_id" : 5,
    "location_type" : "station"
  } ],
  "home_location" : {
    "location_id" : 0,
    "location_type" : "station"
  }
}}]
     - parameter characterId: (path) An EVE character ID 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter token: (query) Access token to use if unable to set a header (optional)

     - returns: RequestBuilder<GetCharactersCharacterIdClonesOk> 
     */
    @MainActor open class func getCharactersCharacterIdClonesWithRequestBuilder(characterId: Int, datasource: Datasource_getCharactersCharacterIdClones? = nil, ifNoneMatch: String? = nil, token: String? = nil) -> RequestBuilder<GetCharactersCharacterIdClonesOk> {
        var path = "/v3/characters/{character_id}/clones/"
        let characterIdPreEscape = "\(characterId)"
        let characterIdPostEscape = characterIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{character_id}", with: characterIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
                        "datasource": datasource?.rawValue, 
                        "token": token
        ])
        let nillableHeaders: [String: Any?] = [
                        "If-None-Match": ifNoneMatch
        ]
        let headerParameters = APIHelper.rejectNilHeaders(nillableHeaders)

        let requestBuilder: RequestBuilder<GetCharactersCharacterIdClonesOk>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
    /**
     * enum for parameter datasource
     */
    public enum Datasource_getCharactersCharacterIdImplants: String { 
        case tranquility = "tranquility"
    }

    /**
     Get active implants

     - parameter characterId: (path) An EVE character ID 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter token: (query) Access token to use if unable to set a header (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    @MainActor open class func getCharactersCharacterIdImplants(characterId: Int, datasource: Datasource_getCharactersCharacterIdImplants? = nil, ifNoneMatch: String? = nil, token: String? = nil, completion: @escaping ((_ data: [Int]?,_ error: Error?) -> Void)) {
        getCharactersCharacterIdImplantsWithRequestBuilder(characterId: characterId, datasource: datasource, ifNoneMatch: ifNoneMatch, token: token).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get active implants
     - GET /v1/characters/{character_id}/implants/

     - OAuth:
       - type: oauth2
       - name: evesso
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - examples: [{contentType=application/json, example=[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]}]
     - parameter characterId: (path) An EVE character ID 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter token: (query) Access token to use if unable to set a header (optional)

     - returns: RequestBuilder<[Int]> 
     */
    @MainActor open class func getCharactersCharacterIdImplantsWithRequestBuilder(characterId: Int, datasource: Datasource_getCharactersCharacterIdImplants? = nil, ifNoneMatch: String? = nil, token: String? = nil) -> RequestBuilder<[Int]> {
        var path = "/v1/characters/{character_id}/implants/"
        let characterIdPreEscape = "\(characterId)"
        let characterIdPostEscape = characterIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{character_id}", with: characterIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
                        "datasource": datasource?.rawValue, 
                        "token": token
        ])
        let nillableHeaders: [String: Any?] = [
                        "If-None-Match": ifNoneMatch
        ]
        let headerParameters = APIHelper.rejectNilHeaders(nillableHeaders)

        let requestBuilder: RequestBuilder<[Int]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
}