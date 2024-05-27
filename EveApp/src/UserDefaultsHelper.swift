//
//  UserDefaultsHelper.swift
//  EveApp
//
//  Created by Erik Hatfield on 6/24/23.
//

import Foundation

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
