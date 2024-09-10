//
//  ThingName.swift
//  
//
//  Created by Erik Hatfield on 8/20/24.
//
import Foundation

public struct AccessTokenResponse: Codable {
    public let access_token: String
    public let expires_in: Int
    public let token_type: String
    public let refresh_token: String
}

public struct ThingName: Codable {
    public let de: String?
    public let en: String?
    public let es: String?
    public let fr: String?
    public let ja: String?
    public let ru: String?
    public let zh: String?
    
    public init(name: String) {
        self.init(en: name)
    }
    
    internal init(
        de: String? = nil,
        en: String? = nil,
        es: String? = nil,
        fr: String? = nil,
        ja: String? = nil,
        ru: String? = nil,
        zh: String? = nil
    ) {
        self.de = de
        self.en = en
        self.es = es
        self.fr = fr
        self.ja = ja
        self.ru = ru
        self.zh = zh
    }
}
