//
//  LoginManager.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/24/23.
//

import Foundation
import OAuthSwift
import CommonCrypto
import CryptoKit

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isLoggedIn = false
    
    var authCode = ""
    var accessToken = ""
    
    let clientId = "df4f768046774997ac8fe9016591aadb"
    let key = "tMaMPzifUyQ8k5elMzDgf0mkgknWbSOPfJd6Zs5U"
    let callbackURL = "eveauth-app://evoauth"
    
    var clientInfo: ClientInfo?
    
    let authorizationCodeURL = "https://login.eveonline.com/v2/oauth/authorize"
    let accessTokenURL = "https://login.eveonline.com/v2/oauth/token"
    
    let state = "testState"
    
    var codeVerifier: String?
    var codeChallenge: String?
    
    var oauthSwift: OAuth2Swift?
    var handler: OAuthSwiftRequestHandle?
    
    private init() { }
    
    func setClientInfo(clientInfo: ClientInfo) {
        self.clientInfo = clientInfo
    }
    
    func generateCodeVerifier() -> String {
        var bytes = ""
        
        for i in 0..<32 {
            bytes.append("\(i % 8)")
        }
        return bytes
    }
    
    
    func login() {
        guard let clientInfo = clientInfo else {
            print("AuthManager.login() no client info")
            return
        }
        let codeVerifier = generateCodeVerifier().toBase64URL()
        self.codeVerifier = codeVerifier
        
        let codeChallenge = codeVerifier.sha256()
        self.codeChallenge = codeChallenge
        
        
        let oauthswift = OAuth2Swift(
            consumerKey: clientInfo.clientID,
            consumerSecret: clientInfo.secretKey,
            authorizeUrl: authorizationCodeURL,
            responseType: "code"
        )
        
        self.oauthSwift = oauthswift
        
        oauthswift.accessTokenBasicAuthentification = true
        let scope = "esi-skills.read_skillqueue.v1"//"esi-characters.read_blueprints.v1"
        let handle = oauthswift.authorize(
            withCallbackURL: URL(string: clientInfo.callbackURL)!,
            scope: scope,
            state: state,
            codeChallenge: codeChallenge,
            codeVerifier: codeVerifier,
            completionHandler: { result in
                switch result {
                case .success(let (credential, response, parameters)):
                    print(credential.oauthToken)
                    // Do your request
                case .failure(let error):
                    print(error)
                    print(error.localizedDescription)
                }
            }
        )
        handler = handle
    }
    
    func outhAuthorize(authCode: String) {
        print("oauthAuthorize")
        guard let codeVerifier = codeVerifier else {
            print("NO CODE VERIFIER")
            return
        }
        
        let authorizeCodeURL = "https://login.eveonline.com/v2/oauth/authorize"
        let accessTokenURL = "https://login.eveonline.com/v2/oauth/token"
        
        let urlString = "https://login.eveonline.com/v2/oauth/token"
        let url = URL(string: urlString)
        
        let oauthswift = OAuth2Swift(
            consumerKey: clientId,
            consumerSecret: key,
            authorizeUrl: authorizeCodeURL,
            accessTokenUrl: accessTokenURL,
            responseType: "code"
        )
        
        self.oauthSwift = oauthswift
        
        let clientAuth = (clientId + ":" + key).toBase64()
        let authHeader = "Basic " + clientAuth
        
        let requestHeaders: [String:String] = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Host": "login.eveonline.com",
        ]
        
        let params: [String: String] = [
            "grant_type": "authorization_code",
            "code": authCode,
            "client_id": clientId,
            "code_verifier": codeVerifier
        ]
        
        var requestBodyComponents = URLComponents()
        
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: authCode),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "code_verifier", value: codeVerifier)
        ]
        
        oauthswift.startAuthorizedRequest(
            url!,
            method: .POST,
            parameters: params,
            headers: requestHeaders,
            body: requestBodyComponents.query?.data(using: .utf8)
        ) { result in
            switch result {
            case .success(let response):
                print("sucess response \(response.dataString())")
                print("")
                self.process(data: response.data)
            case .failure(let error):
                print("error response \(error)")
                print("localized error \(error.localizedDescription)")
            }
            //print("Authorized request result \(result)")
        }
    }
    
    func validate(accessToken: String) {
        let foo = decode(jwtToken: accessToken)
        print("validate: \(foo)")
    }
    
    func process(data: Data) {
        let decoder = JSONDecoder()
        
        do {
            let result = try decoder.decode(AccessTokenResponse.self, from: data)
            self.validate(accessToken: result.access_token)
            print("process data result \(result)")
            UserDefaultsHelper.saveToUserDefaults(data: result, key: .accessTokenResponse)
            isLoggedIn = true
        } catch let error {
            print("Decode error \(error)")
        }
        
    }
    
    func refresh() {
        
    }
    
    func makeCall(url: URL, accessToken: String) {
        self.oauthSwift
    }
}

extension AuthManager {
    func decode(jwtToken jwt: String) -> [String: Any] {
      let segments = jwt.components(separatedBy: ".")
      return decodeJWTPart(segments[1]) ?? [:]
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

    func decodeJWTPart(_ value: String) -> [String: Any]? {
      guard let bodyData = base64UrlDecode(value),
        let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
          return nil
      }

      return payload
    }
}

// MOVE


extension Data{
    
    public func sha256() -> String {
        return hexStringFromData(input: digest(input: self as NSData))
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
    
}


extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8)
            .base64EncodedString()
    }
    
    func toBase64URL() -> String {
        return toBase64()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    func toCleanBase64() -> String {
        return toBase64().replacingOccurrences(of: "=", with: "")
    }
    
    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            
            let hash = SHA256.hash(data: stringData)
            print("sha256 hash \(hash.description)")
            let dataString = Data(hash).base64EncodedString()
            print("data string \(dataString)")
            let base64DataSring = Data(hash).base64EncodedString()
                .replacingOccurrences(of: "=", with: "")
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
            print("clean data string \(base64DataSring)")
            return base64DataSring //.toBase64URL()
//            let hashString = hashed
//                .compactMap { String(format: "%02x", $0) }
//                .joined()
            //return hashString
            
            //return stringData.sha256()
        }
        return ""
    }
    
}


struct AccessTokenResponse: Codable {
    let access_token: String
    let expires_in: Int
    let token_type: String
    let refresh_token: String
}
