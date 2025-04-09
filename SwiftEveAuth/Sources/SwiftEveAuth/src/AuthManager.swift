//
//  AuthManager.swift
//  SwiftEveAuth
//
//  Created by Erik Hatfield on 11/25/24.
//

import Foundation
import OAuthSwift
import CryptoKit

public struct AuthDataResponse {
    public let clientID: String
    public let accessTokenResponse: AccessTokenResponse
    public let accessTokenData: AccessTokenData
}

public protocol AuthManagerDelegate {
    func authManager(didCompleteAuthWith authData: AuthDataResponse)
}

public struct RequestConfig {
    public let url: URL
    public let params: [String: String]
    public let requestHeaders: [String: String]
    public let requestBodyComponents: URLComponents
}

/**
 This class will manage access to authentication keys and refreshing and whatnot
 */
public class AuthManager: ObservableObject {
    let logPrefix = "AuthManager"
    var clientInfo: ClientInfo?
    
    // these need to come from somewhere else
    let authorizationCodeURL = "https://login.eveonline.com/v2/oauth/authorize"
    let accessTokenURL = "https://login.eveonline.com/v2/oauth/token"
    
    let state: String = "TestState"
    
    var codeVerifier: String?
    var codeChallenge: String?
    
    var authConfig: AuthConfig?
    
    var oauthSwift: OAuth2Swift?
    var handler: OAuthSwiftRequestHandle?
    public var delegate: AuthManagerDelegate?
    
    public init(delegate: AuthManagerDelegate?) {
        self.delegate = delegate
        setup()
    }
    
    func setup() {
        loadClientInfo()
    }
    
    func setupAuthConfig() {
        guard let clientInfo = clientInfo else {
            log("login() - no client info")
            return
        }
        let codeVerifier = generateCodeVerifier().toBase64URL()
        
        let authConfig = AuthConfig(
            clientInfo: clientInfo,
            authorizationCodeURL: authorizationCodeURL,
            accessTokenURL: accessTokenURL,
            state: state,
            codeVerifier: codeVerifier,
            codeChallenge: codeVerifier.sha256(),
            scopes: .init(
                [
                    .assets,
                    .skills,
                    .skillQueue,
                    .structureInfo,
                    .characterIndustryJobs,
                    .wallet,
                    .searchStructures
                ]
            )
        )
        print("setupAuthConfig \(authConfig.clientInfo.callbackURL)")
        self.authConfig = authConfig
    }
    
    public func login() {
        setupAuthConfig()
        guard let authConfig = self.authConfig else {
            log("no authConfig")
            return
        }
        
        let oauthswift = OAuth2Swift(
            consumerKey: authConfig.clientInfo.clientID,
            consumerSecret: authConfig.clientInfo.secretKey,
            authorizeUrl: authConfig.authorizationCodeURL,
            responseType: "code"
        )
        self.oauthSwift = oauthswift
        oauthswift.accessTokenBasicAuthentification = true
        //let scope = "\(ESIScopes.assets.rawValue) \(ESIScopes.skillQueue.rawValue)"
        let scope = authConfig.scopes.reduce("", { last, next in
            return last + "\(next.rawValue) "
        })
        print("using callback url \(authConfig.clientInfo.callbackURL)")
        oauthswift.authorize(
            withCallbackURL: URL(string: authConfig.clientInfo.callbackURL)!,
            scope: scope,
            state: authConfig.state,
            codeChallenge: authConfig.codeChallenge,
            codeVerifier: authConfig.codeVerifier,
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
        
        //handler = handle
    }
    
    public func oauthAuthorize(authCode: String) {
        log("oathAuthorize()")
        
        guard let authConfig = self.authConfig else {
            log("No auth config")
            return
        }
        let clientInfo = authConfig.clientInfo
        
        guard let oauthSwift = self.oauthSwift else {
            log("No oauthSwift object")
            return
        }
        
        let requestConfig = requestBuilder(authCode: authCode, authConfig: authConfig)
        
        oauthSwift.startAuthorizedRequest(
            requestConfig.url,
            method: .POST,
            parameters: requestConfig.params,
            headers: requestConfig.requestHeaders,
            body: requestConfig.requestBodyComponents.query?.data(using: .utf8)
        ) { result in
            switch result {
            case .success(let response):
                self.process(data: response.data, clientId: clientInfo.clientID)
            case .failure(let error):
                print("error response \(error)")
                print("localized error \(error.localizedDescription)")
            }
        }
    }
    
    func process(data: Data, clientId: String) {
        log("process()")
        let decoder = JSONDecoder()
        
        do {
            let accessTokenResponse = try decoder.decode(AccessTokenResponse.self, from: data)
            validate(accessToken: accessTokenResponse.access_token)
            //print("process data result \(response)")
            
            guard let accessTokenData = decodeAccessToken(data: accessTokenResponse.access_token) else {
                log("process() - Didnt convert accessToken")
                return
            }

            delegate?.authManager(
                didCompleteAuthWith: AuthDataResponse(
                    clientID: clientId,
                    accessTokenResponse: accessTokenResponse,
                    accessTokenData: accessTokenData
                )
            )
        } catch let error {
            print("Decode error \(error)")
        }
    }
    
    func validate(accessToken: String) {
        print("validate")
        let response = decode(jwtToken: accessToken)
        let decoder = JSONDecoder()
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
            
            let result = try decoder.decode(AccessTokenData.self, from: jsonData)
            print("got characterID result \(result.characterID)")
        } catch let err {
            print("decode error \(err)")
        }
    }
    
    func decodeAccessToken(data: String) -> AccessTokenData? {
        print("decode access token")
        let decoder = JSONDecoder()
        let response = decode(jwtToken: data)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
            return try decoder.decode(AccessTokenData.self, from: jsonData)
        } catch let err {
            print("decode error \(err)")
            return nil
        }
    }
    
    public func refreshTokens(authDatas: [AuthData]) async throws {
        // /*
        log("refreshTokens() \(authDatas.count)")
        if authConfig == nil {
            setupAuthConfig()
        }
        guard let authConfig = self.authConfig else {
            return
        }
        
        let refreshTokens = authDatas.map { $0.refreshToken }
        // eventually we need to call for each synced character
        for refreshToken in refreshTokens {
            let requestConfig = refreshRequestBuilder(refreshToken: refreshToken, authConfig: authConfig)
            
            let oauthSwift = OAuth2Swift(
                consumerKey: authConfig.clientInfo.clientID,
                consumerSecret: authConfig.clientInfo.secretKey,
                authorizeUrl: authConfig.authorizationCodeURL,
                responseType: "code"
            )
            self.oauthSwift = oauthSwift
            
            oauthSwift.startAuthorizedRequest(
                requestConfig.url,
                method: .POST,
                parameters: requestConfig.params,
                headers: requestConfig.requestHeaders,
                body: requestConfig.requestBodyComponents.query?.data(using: .utf8)
            ) { result in
                switch result {
                case .success(let response):
                    self.process(data: response.data, clientId: authConfig.clientInfo.clientID)
                case .failure(let error):
                    print("error response \(error)")
                    print("localized error \(error.localizedDescription)")
                }
            }
        }
 
        // */
    }
}

// MARK: - RequestBuilder
extension AuthManager {
    
    func requestBuilder(authCode: String, authConfig: AuthConfig) -> RequestConfig {
        let urlString = "https://login.eveonline.com/v2/oauth/token"
        let url = URL(string: urlString)
        
        // This can all be a request builder based on AuthConfig
        let clientInfo = authConfig.clientInfo
        
        let params: [String: String] = [
            "grant_type": "authorization_code",
            "code": authCode,
            "client_id": clientInfo.clientID,
            "code_verifier": authConfig.codeVerifier
        ]
        
        let requestHeaders: [String:String] = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Host": "login.eveonline.com",
        ]
        
        var requestBodyComponents = URLComponents()
        
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: authCode),
            URLQueryItem(name: "client_id", value: clientInfo.clientID),
            URLQueryItem(name: "code_verifier", value: authConfig.codeVerifier)
        ]
        
        return RequestConfig(url: url!, params: params, requestHeaders: requestHeaders, requestBodyComponents: requestBodyComponents)
    }
    
    func refreshRequestBuilder(refreshToken: String, authConfig: AuthConfig) -> RequestConfig {
        let urlString = "https://login.eveonline.com/v2/oauth/token"
        let url = URL(string: urlString)
        
        // This can all be a request builder based on AuthConfig
        let clientInfo = authConfig.clientInfo
        let clientAuth = (clientInfo.clientID + ":" + clientInfo.secretKey).toBase64()
        
        let params: [String: String] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
        ]
        
        let requestHeaders: [String:String] = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Host": "login.eveonline.com",
            "Authorization": "Basic \(clientAuth)"
        ]
        
        var requestBodyComponents = URLComponents()
        
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_Token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "client_id", value: clientInfo.clientID),
            URLQueryItem(name: "code_verifier", value: authConfig.codeVerifier)
        ]
        
        return RequestConfig(url: url!, params: params, requestHeaders: requestHeaders, requestBodyComponents: requestBodyComponents)
    }
}


// MARK: - Client Info

extension AuthManager {
    
    func loadClientInfo() {
        log("loadClientInfo()")
        guard let clientInfo = UserDefaultsHelper.loadFromUserDefaults(
            type: ClientInfo.self,
            key: UserDefaultKeys.clientInfo.rawValue
        ) else {
            print("No client info")
            self.clientInfo = nil
            return
        }
        
        self.clientInfo = clientInfo
        log("Client info loaded \(clientInfo.callbackURL)")
    }
    
    public func setClientInfo(clientInfo: ClientInfo) {
        log("setClientInfo()")
        // set into user defaults
        UserDefaultsHelper.saveToUserDefaults(
            data: clientInfo,
            key: .clientInfo
        )
    }
    
}

// MARK: - Helpers

extension AuthManager {
    
    func generateCodeVerifier() -> String {
        var bytes = ""
        
        for i in 0..<32 {
            bytes.append("\(i % 8)")
        }
        
        return bytes
    }
    
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

// MARK: - Logging
extension AuthManager {
    
    func log(_ text: String) {
        print("\(logPrefix) - \(text)")
    }
}

// MARK: - String extension helpers

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


enum UserDefaultKeys: String {
    case clientInfo = "ClientInfo"
    case accessTokenResponse = "AccessTokenResponse"
    case categoryDataResponse = "CategoryDataResponse"
    case categoriesByIdResponse = "CategoriesByIdResponse"
    case groupDataResponse = "GroupDataResponse"
    case groupInfoByIdResponse = "GroupInfoByIdResponse"
    case typeInfoByIdResponse = "TypeInfoByIdResponse"
}

class UserDefaultsHelper {
    static func saveToUserDefaults<T: Codable>(data: T, key: UserDefaultKeys) {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        
        do {
            let encoded = try encoder.encode(data)
            defaults.set(encoded, forKey: key.rawValue)
        } catch let encodeError {
            print("SaveToUserDefaults error: \(encodeError)")
        }
    }
    
    static func loadFromUserDefaults<T: Decodable>(type: T.Type, key: UserDefaultKeys) -> T? {
        return loadFromUserDefaults(type: type, key: key.rawValue)
    }
    
    static func loadFromUserDefaults<T: Decodable>(type: T.Type, key: String) -> T? {
        let defaults = UserDefaults.standard
        let object = defaults.object(forKey: key)
        
        guard let objects = defaults.object(forKey: key) as? Data else {
            print("No object found for \(key)")
            return nil
        }
        
        let decoder = JSONDecoder()
        
        return try? decoder.decode(type, from: objects)
    }
    
    static func hasValueFor(key: UserDefaultKeys) -> Bool {
        return UserDefaults.standard.value(forKey: key.rawValue) != nil
    }
    
    static func removeValue(for key: UserDefaultKeys) {
        let defaults = UserDefaults.standard
        
        defaults.removeObject(forKey: key.rawValue)
    }
}
