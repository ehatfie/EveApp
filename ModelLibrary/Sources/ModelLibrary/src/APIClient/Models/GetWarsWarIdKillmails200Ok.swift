//
// GetWarsWarIdKillmails200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetWarsWarIdKillmails200Ok: Codable {

    /** A hash of this killmail */
    public var killmailHash: String
    /** ID of this killmail */
    public var killmailId: Int

    public init(killmailHash: String, killmailId: Int) {
        self.killmailHash = killmailHash
        self.killmailId = killmailId
    }

    public enum CodingKeys: String, CodingKey { 
        case killmailHash = "killmail_hash"
        case killmailId = "killmail_id"
    }

}
