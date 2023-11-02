//
//  DataManager.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/7/23.
//

import Foundation
import SwiftUI

struct AccessKeyKey: EnvironmentKey {
    static var defaultValue: String? {
        return nil
    }
}


extension EnvironmentValues {
    var accessKey: String? {
        get {
            self[AccessKeyKey.self]
        }
        set {
            self[AccessKeyKey.self] = newValue
        }
    }
}

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    var dbManager: DBManager?
    
    @Published var accessKey: String?
    @Published var accessTokenResponse: AccessTokenResponse? = nil
    @Published var accessTokenData: AccessTokenData?
    
    @Published var characterData: CharacterInfo?
    
    @Published var categoryInfoByID: [Int32: CategoryInfoResponseData] = [:]
    @Published var groupInfoByID: [Int32: GroupInfoResponseData] = [:]
    @Published var typesInfoByID: [Int32: GetUniverseTypesTypeIdOk] = [:]
    
    
    
    
    @Environment(\.accessKey) var accessKey1: String?
    
    private init() {
        DispatchQueue.main.async { [self] in
            loadClientInfo()
            loadAccessTokenResponse()
            loadAccessTokenData()
            loadCharacterData()
//            loadCategoryData()
//            loadGroupData()
//            loadTypeData()
        }
        
    }
    
    func useAccessKey(_ value: String) {
        self.accessKey = value
        
        AuthManager.shared.outhAuthorize(authCode: value)
    }
    
    func loadAccessTokenResponse() {
        guard let foo = UserDefaultsHelper.loadFromUserDefaults(
            type: AccessTokenResponse.self,
            key: UserDefaultKeys.accessTokenResponse.rawValue
        ) else {
            print("didnt get objects")
            return
        }
        
        self.accessTokenResponse = foo
        AuthManager.shared.isLoggedIn = true
    }
    
    func loadCharacterData() {
        
    }
    
    
    func refreshToken() {
        AuthManager.shared.refresh()
    }
    
    func setCharacterPublicData(data: CharacterPublicDataResponse) {
        
    }

}

extension DataManager {
    func validate(accessToken: String) {
        let foo = decode(jwtToken: accessToken)
        print("validate: \(foo)")
    }
    
    func decode(jwtToken jwt: String) -> [String: Any] {
      let segments = jwt.components(separatedBy: ".")
      return decodeJWTPart(segments[1]) ?? [:]
    }
    
    func decodeJWTPart(_ value: String) -> [String: Any]? {
      guard let bodyData = base64UrlDecode(value),
        let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
          return nil
      }

      return payload
    }
    
    func base64UrlDecode(_ value: String) -> Data? {
      var base64 = value
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")

      let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
      let requiredLength = 4 * ceil(length / 4.0)
      let paddingLength = requiredLength - length
      if paddingLength > 0 {
        let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
        base64 = base64 + padding
      }
      return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
}
