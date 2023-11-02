//
// DogmaAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire


open class DogmaAPI {
    /**
     * enum for parameter datasource
     */
    public enum Datasource_getDogmaAttributes: String { 
        case tranquility = "tranquility"
    }

    /**
     Get attributes

     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getDogmaAttributes(datasource: Datasource_getDogmaAttributes? = nil, ifNoneMatch: String? = nil, completion: @escaping ((_ data: [Int]?,_ error: Error?) -> Void)) {
        getDogmaAttributesWithRequestBuilder(datasource: datasource, ifNoneMatch: ifNoneMatch).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get attributes
     - GET /v1/dogma/attributes/

     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - examples: [{contentType=application/json, example=[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]}]
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)

     - returns: RequestBuilder<[Int]> 
     */
    open class func getDogmaAttributesWithRequestBuilder(datasource: Datasource_getDogmaAttributes? = nil, ifNoneMatch: String? = nil) -> RequestBuilder<[Int]> {
        let path = "/v1/dogma/attributes/"
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

        let requestBuilder: RequestBuilder<[Int]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
    /**
     * enum for parameter datasource
     */
    public enum Datasource_getDogmaAttributesAttributeId: String { 
        case tranquility = "tranquility"
    }

    /**
     Get attribute information

     - parameter attributeId: (path) A dogma attribute ID 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getDogmaAttributesAttributeId(attributeId: Int, datasource: Datasource_getDogmaAttributesAttributeId? = nil, ifNoneMatch: String? = nil, completion: @escaping ((_ data: GetDogmaAttributesAttributeIdOk?,_ error: Error?) -> Void)) {
        getDogmaAttributesAttributeIdWithRequestBuilder(attributeId: attributeId, datasource: datasource, ifNoneMatch: ifNoneMatch).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get attribute information
     - GET /v1/dogma/attributes/{attribute_id}/

     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - examples: [{contentType=application/json, example={
  "stackable" : true,
  "attribute_id" : 0,
  "name" : "name",
  "description" : "description",
  "default_value" : 6.0274563,
  "published" : true,
  "display_name" : "display_name",
  "icon_id" : 1,
  "high_is_good" : true,
  "unit_id" : 5
}}]
     - parameter attributeId: (path) A dogma attribute ID 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)

     - returns: RequestBuilder<GetDogmaAttributesAttributeIdOk> 
     */
    open class func getDogmaAttributesAttributeIdWithRequestBuilder(attributeId: Int, datasource: Datasource_getDogmaAttributesAttributeId? = nil, ifNoneMatch: String? = nil) -> RequestBuilder<GetDogmaAttributesAttributeIdOk> {
        var path = "/v1/dogma/attributes/{attribute_id}/"
        let attributeIdPreEscape = "\(attributeId)"
        let attributeIdPostEscape = attributeIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{attribute_id}", with: attributeIdPostEscape, options: .literal, range: nil)
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

        let requestBuilder: RequestBuilder<GetDogmaAttributesAttributeIdOk>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
    /**
     * enum for parameter datasource
     */
    public enum Datasource_getDogmaDynamicItemsTypeIdItemId: String { 
        case tranquility = "tranquility"
    }

    /**
     Get dynamic item information

     - parameter itemId: (path) item_id integer 
     - parameter typeId: (path) type_id integer 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getDogmaDynamicItemsTypeIdItemId(itemId: Int64, typeId: Int, datasource: Datasource_getDogmaDynamicItemsTypeIdItemId? = nil, ifNoneMatch: String? = nil, completion: @escaping ((_ data: GetDogmaDynamicItemsTypeIdItemIdOk?,_ error: Error?) -> Void)) {
        getDogmaDynamicItemsTypeIdItemIdWithRequestBuilder(itemId: itemId, typeId: typeId, datasource: datasource, ifNoneMatch: ifNoneMatch).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get dynamic item information
     - GET /v1/dogma/dynamic/items/{type_id}/{item_id}/

     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - examples: [{contentType=application/json, example={
  "mutator_type_id" : 5,
  "dogma_attributes" : [ {
    "attribute_id" : 6,
    "value" : 1.4658129
  }, {
    "attribute_id" : 6,
    "value" : 1.4658129
  }, {
    "attribute_id" : 6,
    "value" : 1.4658129
  }, {
    "attribute_id" : 6,
    "value" : 1.4658129
  }, {
    "attribute_id" : 6,
    "value" : 1.4658129
  }, {
    "attribute_id" : 6,
    "value" : 1.4658129
  }, {
    "attribute_id" : 6,
    "value" : 1.4658129
  }, {
    "attribute_id" : 6,
    "value" : 1.4658129
  }, {
    "attribute_id" : 6,
    "value" : 1.4658129
  }, {
    "attribute_id" : 6,
    "value" : 1.4658129
  } ],
  "source_type_id" : 2,
  "created_by" : 0,
  "dogma_effects" : [ {
    "is_default" : true,
    "effect_id" : 5
  }, {
    "is_default" : true,
    "effect_id" : 5
  }, {
    "is_default" : true,
    "effect_id" : 5
  }, {
    "is_default" : true,
    "effect_id" : 5
  }, {
    "is_default" : true,
    "effect_id" : 5
  }, {
    "is_default" : true,
    "effect_id" : 5
  }, {
    "is_default" : true,
    "effect_id" : 5
  }, {
    "is_default" : true,
    "effect_id" : 5
  }, {
    "is_default" : true,
    "effect_id" : 5
  }, {
    "is_default" : true,
    "effect_id" : 5
  } ]
}}]
     - parameter itemId: (path) item_id integer 
     - parameter typeId: (path) type_id integer 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)

     - returns: RequestBuilder<GetDogmaDynamicItemsTypeIdItemIdOk> 
     */
    open class func getDogmaDynamicItemsTypeIdItemIdWithRequestBuilder(itemId: Int64, typeId: Int, datasource: Datasource_getDogmaDynamicItemsTypeIdItemId? = nil, ifNoneMatch: String? = nil) -> RequestBuilder<GetDogmaDynamicItemsTypeIdItemIdOk> {
        var path = "/v1/dogma/dynamic/items/{type_id}/{item_id}/"
        let itemIdPreEscape = "\(itemId)"
        let itemIdPostEscape = itemIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{item_id}", with: itemIdPostEscape, options: .literal, range: nil)
        let typeIdPreEscape = "\(typeId)"
        let typeIdPostEscape = typeIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{type_id}", with: typeIdPostEscape, options: .literal, range: nil)
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

        let requestBuilder: RequestBuilder<GetDogmaDynamicItemsTypeIdItemIdOk>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
    /**
     * enum for parameter datasource
     */
    public enum Datasource_getDogmaEffects: String { 
        case tranquility = "tranquility"
    }

    /**
     Get effects

     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getDogmaEffects(datasource: Datasource_getDogmaEffects? = nil, ifNoneMatch: String? = nil, completion: @escaping ((_ data: [Int]?,_ error: Error?) -> Void)) {
        getDogmaEffectsWithRequestBuilder(datasource: datasource, ifNoneMatch: ifNoneMatch).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get effects
     - GET /v1/dogma/effects/

     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - examples: [{contentType=application/json, example=[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]}]
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)

     - returns: RequestBuilder<[Int]> 
     */
    open class func getDogmaEffectsWithRequestBuilder(datasource: Datasource_getDogmaEffects? = nil, ifNoneMatch: String? = nil) -> RequestBuilder<[Int]> {
        let path = "/v1/dogma/effects/"
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

        let requestBuilder: RequestBuilder<[Int]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
    /**
     * enum for parameter datasource
     */
    public enum Datasource_getDogmaEffectsEffectId: String { 
        case tranquility = "tranquility"
    }

    /**
     Get effect information

     - parameter effectId: (path) A dogma effect ID 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    open class func getDogmaEffectsEffectId(effectId: Int, datasource: Datasource_getDogmaEffectsEffectId? = nil, ifNoneMatch: String? = nil, completion: @escaping ((_ data: GetDogmaEffectsEffectIdOk?,_ error: Error?) -> Void)) {
        getDogmaEffectsEffectIdWithRequestBuilder(effectId: effectId, datasource: datasource, ifNoneMatch: ifNoneMatch).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get effect information
     - GET /v2/dogma/effects/{effect_id}/

     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - examples: [{contentType=application/json, example={
  "pre_expression" : 7,
  "duration_attribute_id" : 6,
  "description" : "description",
  "post_expression" : 4,
  "published" : true,
  "display_name" : "display_name",
  "icon_id" : 2,
  "modifiers" : [ {
    "modifying_attribute_id" : 3,
    "func" : "func",
    "domain" : "domain",
    "modified_attribute_id" : 9,
    "operator" : 2,
    "effect_id" : 7
  }, {
    "modifying_attribute_id" : 3,
    "func" : "func",
    "domain" : "domain",
    "modified_attribute_id" : 9,
    "operator" : 2,
    "effect_id" : 7
  }, {
    "modifying_attribute_id" : 3,
    "func" : "func",
    "domain" : "domain",
    "modified_attribute_id" : 9,
    "operator" : 2,
    "effect_id" : 7
  }, {
    "modifying_attribute_id" : 3,
    "func" : "func",
    "domain" : "domain",
    "modified_attribute_id" : 9,
    "operator" : 2,
    "effect_id" : 7
  }, {
    "modifying_attribute_id" : 3,
    "func" : "func",
    "domain" : "domain",
    "modified_attribute_id" : 9,
    "operator" : 2,
    "effect_id" : 7
  }, {
    "modifying_attribute_id" : 3,
    "func" : "func",
    "domain" : "domain",
    "modified_attribute_id" : 9,
    "operator" : 2,
    "effect_id" : 7
  }, {
    "modifying_attribute_id" : 3,
    "func" : "func",
    "domain" : "domain",
    "modified_attribute_id" : 9,
    "operator" : 2,
    "effect_id" : 7
  }, {
    "modifying_attribute_id" : 3,
    "func" : "func",
    "domain" : "domain",
    "modified_attribute_id" : 9,
    "operator" : 2,
    "effect_id" : 7
  }, {
    "modifying_attribute_id" : 3,
    "func" : "func",
    "domain" : "domain",
    "modified_attribute_id" : 9,
    "operator" : 2,
    "effect_id" : 7
  }, {
    "modifying_attribute_id" : 3,
    "func" : "func",
    "domain" : "domain",
    "modified_attribute_id" : 9,
    "operator" : 2,
    "effect_id" : 7
  } ],
  "discharge_attribute_id" : 0,
  "range_chance" : true,
  "tracking_speed_attribute_id" : 1,
  "range_attribute_id" : 1,
  "is_assistance" : true,
  "electronic_chance" : true,
  "disallow_auto_repeat" : true,
  "effect_category" : 1,
  "falloff_attribute_id" : 5,
  "name" : "name",
  "is_warp_safe" : true,
  "effect_id" : 5,
  "is_offensive" : true
}}]
     - parameter effectId: (path) A dogma effect ID 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)

     - returns: RequestBuilder<GetDogmaEffectsEffectIdOk> 
     */
    open class func getDogmaEffectsEffectIdWithRequestBuilder(effectId: Int, datasource: Datasource_getDogmaEffectsEffectId? = nil, ifNoneMatch: String? = nil) -> RequestBuilder<GetDogmaEffectsEffectIdOk> {
        var path = "/v2/dogma/effects/{effect_id}/"
        let effectIdPreEscape = "\(effectId)"
        let effectIdPostEscape = effectIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{effect_id}", with: effectIdPostEscape, options: .literal, range: nil)
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

        let requestBuilder: RequestBuilder<GetDogmaEffectsEffectIdOk>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
}
