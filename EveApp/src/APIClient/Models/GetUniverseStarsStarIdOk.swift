//
// GetUniverseStarsStarIdOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetUniverseStarsStarIdOk: Codable {

    public enum SpectralClass: String, Codable { 
        case k2V = "K2 V"
        case k4V = "K4 V"
        case g2V = "G2 V"
        case g8V = "G8 V"
        case m7V = "M7 V"
        case k7V = "K7 V"
        case m2V = "M2 V"
        case k5V = "K5 V"
        case m3V = "M3 V"
        case g0V = "G0 V"
        case g7V = "G7 V"
        case g3V = "G3 V"
        case f9V = "F9 V"
        case g5V = "G5 V"
        case f6V = "F6 V"
        case k8V = "K8 V"
        case k9V = "K9 V"
        case k6V = "K6 V"
        case g9V = "G9 V"
        case g6V = "G6 V"
        case g4Vi = "G4 VI"
        case g4V = "G4 V"
        case f8V = "F8 V"
        case f2V = "F2 V"
        case f1V = "F1 V"
        case k3V = "K3 V"
        case f0Vi = "F0 VI"
        case g1Vi = "G1 VI"
        case g0Vi = "G0 VI"
        case k1V = "K1 V"
        case m4V = "M4 V"
        case m1V = "M1 V"
        case m6V = "M6 V"
        case m0V = "M0 V"
        case k2Iv = "K2 IV"
        case g2Vi = "G2 VI"
        case k0V = "K0 V"
        case k5Iv = "K5 IV"
        case f5Vi = "F5 VI"
        case g6Vi = "G6 VI"
        case f6Vi = "F6 VI"
        case f2Iv = "F2 IV"
        case g3Vi = "G3 VI"
        case m8V = "M8 V"
        case f1Vi = "F1 VI"
        case k1Iv = "K1 IV"
        case f7V = "F7 V"
        case g5Vi = "G5 VI"
        case m5V = "M5 V"
        case g7Vi = "G7 VI"
        case f5V = "F5 V"
        case f4Vi = "F4 VI"
        case f8Vi = "F8 VI"
        case k3Iv = "K3 IV"
        case f4Iv = "F4 IV"
        case f0V = "F0 V"
        case g7Iv = "G7 IV"
        case g8Vi = "G8 VI"
        case f2Vi = "F2 VI"
        case f4V = "F4 V"
        case f7Vi = "F7 VI"
        case f3V = "F3 V"
        case g1V = "G1 V"
        case g9Vi = "G9 VI"
        case f3Iv = "F3 IV"
        case f9Vi = "F9 VI"
        case m9V = "M9 V"
        case k0Iv = "K0 IV"
        case f1Iv = "F1 IV"
        case g4Iv = "G4 IV"
        case f3Vi = "F3 VI"
        case k4Iv = "K4 IV"
        case g5Iv = "G5 IV"
        case g3Iv = "G3 IV"
        case g1Iv = "G1 IV"
        case k7Iv = "K7 IV"
        case g0Iv = "G0 IV"
        case k6Iv = "K6 IV"
        case k9Iv = "K9 IV"
        case g2Iv = "G2 IV"
        case f9Iv = "F9 IV"
        case f0Iv = "F0 IV"
        case k8Iv = "K8 IV"
        case g8Iv = "G8 IV"
        case f6Iv = "F6 IV"
        case f5Iv = "F5 IV"
        case a0 = "A0"
        case a0IV = "A0IV"
        case a0IV2 = "A0IV2"
    }
    /** Age of star in years */
    public var age: Int64
    /** luminosity number */
    public var luminosity: Float
    /** name string */
    public var name: String
    /** radius integer */
    public var radius: Int64
    /** solar_system_id integer */
    public var solarSystemId: Int
    /** spectral_class string */
    public var spectralClass: SpectralClass
    /** temperature integer */
    public var temperature: Int
    /** type_id integer */
    public var typeId: Int

    public init(age: Int64, luminosity: Float, name: String, radius: Int64, solarSystemId: Int, spectralClass: SpectralClass, temperature: Int, typeId: Int) {
        self.age = age
        self.luminosity = luminosity
        self.name = name
        self.radius = radius
        self.solarSystemId = solarSystemId
        self.spectralClass = spectralClass
        self.temperature = temperature
        self.typeId = typeId
    }

    public enum CodingKeys: String, CodingKey { 
        case age
        case luminosity
        case name
        case radius
        case solarSystemId = "solar_system_id"
        case spectralClass = "spectral_class"
        case temperature
        case typeId = "type_id"
    }

}
