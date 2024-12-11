//
// GetCharactersCharacterIdMailLists200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCharactersCharacterIdMailLists200Ok: Codable {

    /** Mailing list ID */
    public var mailingListId: Int
    /** name string */
    public var name: String

    public init(mailingListId: Int, name: String) {
        self.mailingListId = mailingListId
        self.name = name
    }

    public enum CodingKeys: String, CodingKey { 
        case mailingListId = "mailing_list_id"
        case name
    }

}