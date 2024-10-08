//
// IncursionsAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire


@MainActor open class IncursionsAPI {
    /**
     * enum for parameter datasource
     */
    public enum Datasource_getIncursions: String { 
        case tranquility = "tranquility"
    }

    /**
     List incursions

     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    @MainActor open class func getIncursions(datasource: Datasource_getIncursions? = nil, ifNoneMatch: String? = nil, completion: @escaping ((_ data: [GetIncursions200Ok]?,_ error: Error?) -> Void)) {
        getIncursionsWithRequestBuilder(datasource: datasource, ifNoneMatch: ifNoneMatch).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     List incursions
     - GET /v1/incursions/

     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - examples: [{contentType=application/json, example=[ {
  "faction_id" : 6,
  "state" : "withdrawing",
  "type" : "type",
  "staging_solar_system_id" : 5,
  "constellation_id" : 0,
  "has_boss" : true,
  "infested_solar_systems" : [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
  "influence" : 5.962134
}, {
  "faction_id" : 6,
  "state" : "withdrawing",
  "type" : "type",
  "staging_solar_system_id" : 5,
  "constellation_id" : 0,
  "has_boss" : true,
  "infested_solar_systems" : [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
  "influence" : 5.962134
}, {
  "faction_id" : 6,
  "state" : "withdrawing",
  "type" : "type",
  "staging_solar_system_id" : 5,
  "constellation_id" : 0,
  "has_boss" : true,
  "infested_solar_systems" : [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
  "influence" : 5.962134
}, {
  "faction_id" : 6,
  "state" : "withdrawing",
  "type" : "type",
  "staging_solar_system_id" : 5,
  "constellation_id" : 0,
  "has_boss" : true,
  "infested_solar_systems" : [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
  "influence" : 5.962134
}, {
  "faction_id" : 6,
  "state" : "withdrawing",
  "type" : "type",
  "staging_solar_system_id" : 5,
  "constellation_id" : 0,
  "has_boss" : true,
  "infested_solar_systems" : [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
  "influence" : 5.962134
}, {
  "faction_id" : 6,
  "state" : "withdrawing",
  "type" : "type",
  "staging_solar_system_id" : 5,
  "constellation_id" : 0,
  "has_boss" : true,
  "infested_solar_systems" : [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
  "influence" : 5.962134
}, {
  "faction_id" : 6,
  "state" : "withdrawing",
  "type" : "type",
  "staging_solar_system_id" : 5,
  "constellation_id" : 0,
  "has_boss" : true,
  "infested_solar_systems" : [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
  "influence" : 5.962134
}, {
  "faction_id" : 6,
  "state" : "withdrawing",
  "type" : "type",
  "staging_solar_system_id" : 5,
  "constellation_id" : 0,
  "has_boss" : true,
  "infested_solar_systems" : [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
  "influence" : 5.962134
}, {
  "faction_id" : 6,
  "state" : "withdrawing",
  "type" : "type",
  "staging_solar_system_id" : 5,
  "constellation_id" : 0,
  "has_boss" : true,
  "infested_solar_systems" : [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
  "influence" : 5.962134
}, {
  "faction_id" : 6,
  "state" : "withdrawing",
  "type" : "type",
  "staging_solar_system_id" : 5,
  "constellation_id" : 0,
  "has_boss" : true,
  "infested_solar_systems" : [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
  "influence" : 5.962134
} ]}]
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)

     - returns: RequestBuilder<[GetIncursions200Ok]> 
     */
    @MainActor open class func getIncursionsWithRequestBuilder(datasource: Datasource_getIncursions? = nil, ifNoneMatch: String? = nil) -> RequestBuilder<[GetIncursions200Ok]> {
        let path = "/v1/incursions/"
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

        let requestBuilder: RequestBuilder<[GetIncursions200Ok]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
}
