//
// CalendarAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation
import Alamofire


@MainActor open class CalendarAPI {
    /**
     * enum for parameter datasource
     */
    public enum Datasource_getCharactersCharacterIdCalendar: String { 
        case tranquility = "tranquility"
    }

    /**
     List calendar event summaries

     - parameter characterId: (path) An EVE character ID 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter fromEvent: (query) The event ID to retrieve events from (optional)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter token: (query) Access token to use if unable to set a header (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    @MainActor open class func getCharactersCharacterIdCalendar(characterId: Int, datasource: Datasource_getCharactersCharacterIdCalendar? = nil, fromEvent: Int? = nil, ifNoneMatch: String? = nil, token: String? = nil, completion: @escaping ((_ data: [GetCharactersCharacterIdCalendar200Ok]?,_ error: Error?) -> Void)) {
        getCharactersCharacterIdCalendarWithRequestBuilder(characterId: characterId, datasource: datasource, fromEvent: fromEvent, ifNoneMatch: ifNoneMatch, token: token).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     List calendar event summaries
     - GET /v1/characters/{character_id}/calendar/

     - OAuth:
       - type: oauth2
       - name: evesso
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - examples: [{contentType=application/json, example=[ {
  "event_response" : "declined",
  "event_id" : 0,
  "importance" : 6,
  "event_date" : "2000-01-23T04:56:07.000+00:00",
  "title" : "title"
}, {
  "event_response" : "declined",
  "event_id" : 0,
  "importance" : 6,
  "event_date" : "2000-01-23T04:56:07.000+00:00",
  "title" : "title"
}, {
  "event_response" : "declined",
  "event_id" : 0,
  "importance" : 6,
  "event_date" : "2000-01-23T04:56:07.000+00:00",
  "title" : "title"
}, {
  "event_response" : "declined",
  "event_id" : 0,
  "importance" : 6,
  "event_date" : "2000-01-23T04:56:07.000+00:00",
  "title" : "title"
}, {
  "event_response" : "declined",
  "event_id" : 0,
  "importance" : 6,
  "event_date" : "2000-01-23T04:56:07.000+00:00",
  "title" : "title"
}, {
  "event_response" : "declined",
  "event_id" : 0,
  "importance" : 6,
  "event_date" : "2000-01-23T04:56:07.000+00:00",
  "title" : "title"
}, {
  "event_response" : "declined",
  "event_id" : 0,
  "importance" : 6,
  "event_date" : "2000-01-23T04:56:07.000+00:00",
  "title" : "title"
}, {
  "event_response" : "declined",
  "event_id" : 0,
  "importance" : 6,
  "event_date" : "2000-01-23T04:56:07.000+00:00",
  "title" : "title"
}, {
  "event_response" : "declined",
  "event_id" : 0,
  "importance" : 6,
  "event_date" : "2000-01-23T04:56:07.000+00:00",
  "title" : "title"
}, {
  "event_response" : "declined",
  "event_id" : 0,
  "importance" : 6,
  "event_date" : "2000-01-23T04:56:07.000+00:00",
  "title" : "title"
} ]}]
     - parameter characterId: (path) An EVE character ID 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter fromEvent: (query) The event ID to retrieve events from (optional)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter token: (query) Access token to use if unable to set a header (optional)

     - returns: RequestBuilder<[GetCharactersCharacterIdCalendar200Ok]> 
     */
    @MainActor open class func getCharactersCharacterIdCalendarWithRequestBuilder(characterId: Int, datasource: Datasource_getCharactersCharacterIdCalendar? = nil, fromEvent: Int? = nil, ifNoneMatch: String? = nil, token: String? = nil) -> RequestBuilder<[GetCharactersCharacterIdCalendar200Ok]> {
        var path = "/v1/characters/{character_id}/calendar/"
        let characterIdPreEscape = "\(characterId)"
        let characterIdPostEscape = characterIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{character_id}", with: characterIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters: [String:Any]? = nil
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
                        "datasource": datasource?.rawValue, 
                        "from_event": fromEvent?.encodeToJSON(), 
                        "token": token
        ])
        let nillableHeaders: [String: Any?] = [
                        "If-None-Match": ifNoneMatch
        ]
        let headerParameters = APIHelper.rejectNilHeaders(nillableHeaders)

        let requestBuilder: RequestBuilder<[GetCharactersCharacterIdCalendar200Ok]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
    /**
     * enum for parameter datasource
     */
    public enum Datasource_getCharactersCharacterIdCalendarEventId: String { 
        case tranquility = "tranquility"
    }

    /**
     Get an event

     - parameter characterId: (path) An EVE character ID 
     - parameter eventId: (path) The id of the event requested 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter token: (query) Access token to use if unable to set a header (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    @MainActor open class func getCharactersCharacterIdCalendarEventId(characterId: Int, eventId: Int, datasource: Datasource_getCharactersCharacterIdCalendarEventId? = nil, ifNoneMatch: String? = nil, token: String? = nil, completion: @escaping ((_ data: GetCharactersCharacterIdCalendarEventIdOk?,_ error: Error?) -> Void)) {
        getCharactersCharacterIdCalendarEventIdWithRequestBuilder(characterId: characterId, eventId: eventId, datasource: datasource, ifNoneMatch: ifNoneMatch, token: token).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get an event
     - GET /v3/characters/{character_id}/calendar/{event_id}/

     - OAuth:
       - type: oauth2
       - name: evesso
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - examples: [{contentType=application/json, example={
  "date" : "2000-01-23T04:56:07.000+00:00",
  "duration" : 0,
  "event_id" : 6,
  "owner_name" : "owner_name",
  "importance" : 1,
  "owner_id" : 5,
  "response" : "response",
  "text" : "text",
  "title" : "title",
  "owner_type" : "eve_server"
}}]
     - parameter characterId: (path) An EVE character ID 
     - parameter eventId: (path) The id of the event requested 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter token: (query) Access token to use if unable to set a header (optional)

     - returns: RequestBuilder<GetCharactersCharacterIdCalendarEventIdOk> 
     */
    @MainActor open class func getCharactersCharacterIdCalendarEventIdWithRequestBuilder(characterId: Int, eventId: Int, datasource: Datasource_getCharactersCharacterIdCalendarEventId? = nil, ifNoneMatch: String? = nil, token: String? = nil) -> RequestBuilder<GetCharactersCharacterIdCalendarEventIdOk> {
        var path = "/v3/characters/{character_id}/calendar/{event_id}/"
        let characterIdPreEscape = "\(characterId)"
        let characterIdPostEscape = characterIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{character_id}", with: characterIdPostEscape, options: .literal, range: nil)
        let eventIdPreEscape = "\(eventId)"
        let eventIdPostEscape = eventIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{event_id}", with: eventIdPostEscape, options: .literal, range: nil)
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

        let requestBuilder: RequestBuilder<GetCharactersCharacterIdCalendarEventIdOk>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
    /**
     * enum for parameter datasource
     */
    public enum Datasource_getCharactersCharacterIdCalendarEventIdAttendees: String { 
        case tranquility = "tranquility"
    }

    /**
     Get attendees

     - parameter characterId: (path) An EVE character ID 
     - parameter eventId: (path) The id of the event requested 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter token: (query) Access token to use if unable to set a header (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    @MainActor open class func getCharactersCharacterIdCalendarEventIdAttendees(characterId: Int, eventId: Int, datasource: Datasource_getCharactersCharacterIdCalendarEventIdAttendees? = nil, ifNoneMatch: String? = nil, token: String? = nil, completion: @escaping ((_ data: [GetCharactersCharacterIdCalendarEventIdAttendees200Ok]?,_ error: Error?) -> Void)) {
        getCharactersCharacterIdCalendarEventIdAttendeesWithRequestBuilder(characterId: characterId, eventId: eventId, datasource: datasource, ifNoneMatch: ifNoneMatch, token: token).execute { (response, error) -> Void in
            completion(response?.body, error)
        }
    }


    /**
     Get attendees
     - GET /v1/characters/{character_id}/calendar/{event_id}/attendees/

     - OAuth:
       - type: oauth2
       - name: evesso
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - responseHeaders: [Cache-Control(String), ETag(String), Expires(String), Last-Modified(String)]
     - examples: [{contentType=application/json, example=[ {
  "event_response" : "declined",
  "character_id" : 0
}, {
  "event_response" : "declined",
  "character_id" : 0
}, {
  "event_response" : "declined",
  "character_id" : 0
}, {
  "event_response" : "declined",
  "character_id" : 0
}, {
  "event_response" : "declined",
  "character_id" : 0
}, {
  "event_response" : "declined",
  "character_id" : 0
}, {
  "event_response" : "declined",
  "character_id" : 0
}, {
  "event_response" : "declined",
  "character_id" : 0
}, {
  "event_response" : "declined",
  "character_id" : 0
}, {
  "event_response" : "declined",
  "character_id" : 0
} ]}]
     - parameter characterId: (path) An EVE character ID 
     - parameter eventId: (path) The id of the event requested 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter ifNoneMatch: (header) ETag from a previous request. A 304 will be returned if this matches the current ETag (optional)
     - parameter token: (query) Access token to use if unable to set a header (optional)

     - returns: RequestBuilder<[GetCharactersCharacterIdCalendarEventIdAttendees200Ok]> 
     */
    @MainActor open class func getCharactersCharacterIdCalendarEventIdAttendeesWithRequestBuilder(characterId: Int, eventId: Int, datasource: Datasource_getCharactersCharacterIdCalendarEventIdAttendees? = nil, ifNoneMatch: String? = nil, token: String? = nil) -> RequestBuilder<[GetCharactersCharacterIdCalendarEventIdAttendees200Ok]> {
        var path = "/v1/characters/{character_id}/calendar/{event_id}/attendees/"
        let characterIdPreEscape = "\(characterId)"
        let characterIdPostEscape = characterIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{character_id}", with: characterIdPostEscape, options: .literal, range: nil)
        let eventIdPreEscape = "\(eventId)"
        let eventIdPostEscape = eventIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{event_id}", with: eventIdPostEscape, options: .literal, range: nil)
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

        let requestBuilder: RequestBuilder<[GetCharactersCharacterIdCalendarEventIdAttendees200Ok]>.Type = SwaggerClientAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: (url?.string ?? URLString), parameters: parameters, isBody: false, headers: headerParameters)
    }
    /**
     * enum for parameter datasource
     */
    public enum Datasource_putCharactersCharacterIdCalendarEventId: String { 
        case tranquility = "tranquility"
    }

    /**
     Respond to an event

     - parameter body: (body) The response value to set, overriding current value 
     - parameter characterId: (path) An EVE character ID 
     - parameter eventId: (path) The ID of the event requested 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter token: (query) Access token to use if unable to set a header (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    @MainActor open class func putCharactersCharacterIdCalendarEventId(body: PutCharactersCharacterIdCalendarEventIdResponse, characterId: Int, eventId: Int, datasource: Datasource_putCharactersCharacterIdCalendarEventId? = nil, token: String? = nil, completion: @escaping ((_ data: Void?,_ error: Error?) -> Void)) {
        putCharactersCharacterIdCalendarEventIdWithRequestBuilder(body: body, characterId: characterId, eventId: eventId, datasource: datasource, token: token).execute { (response, error) -> Void in
            if error == nil {
                completion((), error)
            } else {
                completion(nil, error)
            }
        }
    }


    /**
     Respond to an event
     - PUT /v3/characters/{character_id}/calendar/{event_id}/

     - OAuth:
       - type: oauth2
       - name: evesso
     - parameter body: (body) The response value to set, overriding current value 
     - parameter characterId: (path) An EVE character ID 
     - parameter eventId: (path) The ID of the event requested 
     - parameter datasource: (query) The server name you would like data from (optional, default to tranquility)
     - parameter token: (query) Access token to use if unable to set a header (optional)

     - returns: RequestBuilder<Void> 
     */
    @MainActor open class func putCharactersCharacterIdCalendarEventIdWithRequestBuilder(body: PutCharactersCharacterIdCalendarEventIdResponse, characterId: Int, eventId: Int, datasource: Datasource_putCharactersCharacterIdCalendarEventId? = nil, token: String? = nil) -> RequestBuilder<Void> {
        var path = "/v3/characters/{character_id}/calendar/{event_id}/"
        let characterIdPreEscape = "\(characterId)"
        let characterIdPostEscape = characterIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{character_id}", with: characterIdPostEscape, options: .literal, range: nil)
        let eventIdPreEscape = "\(eventId)"
        let eventIdPostEscape = eventIdPreEscape.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        path = path.replacingOccurrences(of: "{event_id}", with: eventIdPostEscape, options: .literal, range: nil)
        let URLString = SwaggerClientAPI.basePath + path
        let parameters = JSONEncodingHelper.encodingParameters(forEncodableObject: body)
        var url = URLComponents(string: URLString)
        url?.queryItems = APIHelper.mapValuesToQueryItems([
                        "datasource": datasource?.rawValue, 
                        "token": token
        ])


        let requestBuilder: RequestBuilder<Void>.Type = SwaggerClientAPI.requestBuilderFactory.getNonDecodableBuilder()

        return requestBuilder.init(method: "PUT", URLString: (url?.string ?? URLString), parameters: parameters, isBody: true)
    }
}
