//
// GetCharactersCharacterIdMail200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCharactersCharacterIdMail200Ok: Codable {

    /** From whom the mail was sent */
    public var from: Int?
    /** is_read boolean */
    public var isRead: Bool?
    /** labels array */
    public var labels: [Int]?
    /** mail_id integer */
    public var mailId: Int?
    /** Recipients of the mail */
    public var recipients: [GetCharactersCharacterIdMailRecipient]?
    /** Mail subject */
    public var subject: String?
    /** When the mail was sent */
    public var timestamp: Date?

    public init(from: Int? = nil, isRead: Bool? = nil, labels: [Int]? = nil, mailId: Int? = nil, recipients: [GetCharactersCharacterIdMailRecipient]? = nil, subject: String? = nil, timestamp: Date? = nil) {
        self.from = from
        self.isRead = isRead
        self.labels = labels
        self.mailId = mailId
        self.recipients = recipients
        self.subject = subject
        self.timestamp = timestamp
    }

    public enum CodingKeys: String, CodingKey { 
        case from
        case isRead = "is_read"
        case labels
        case mailId = "mail_id"
        case recipients
        case subject
        case timestamp
    }

}
