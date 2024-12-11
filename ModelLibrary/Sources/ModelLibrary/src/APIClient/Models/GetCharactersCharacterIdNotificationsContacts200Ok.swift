//
// GetCharactersCharacterIdNotificationsContacts200Ok.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetCharactersCharacterIdNotificationsContacts200Ok: Codable {

    /** message string */
    public var message: String
    /** notification_id integer */
    public var notificationId: Int
    /** send_date string */
    public var sendDate: Date
    /** sender_character_id integer */
    public var senderCharacterId: Int
    /** A number representing the standing level the receiver has been added at by the sender. The standing levels are as follows: -10 -&gt; Terrible | -5 -&gt; Bad |  0 -&gt; Neutral |  5 -&gt; Good |  10 -&gt; Excellent */
    public var standingLevel: Float

    public init(message: String, notificationId: Int, sendDate: Date, senderCharacterId: Int, standingLevel: Float) {
        self.message = message
        self.notificationId = notificationId
        self.sendDate = sendDate
        self.senderCharacterId = senderCharacterId
        self.standingLevel = standingLevel
    }

    public enum CodingKeys: String, CodingKey { 
        case message
        case notificationId = "notification_id"
        case sendDate = "send_date"
        case senderCharacterId = "sender_character_id"
        case standingLevel = "standing_level"
    }

}