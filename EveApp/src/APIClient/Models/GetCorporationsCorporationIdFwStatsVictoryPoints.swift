//
// GetCorporationsCorporationIdFwStatsVictoryPoints.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** Summary of victory points gained by the given corporation for the enlisted faction */

public struct GetCorporationsCorporationIdFwStatsVictoryPoints: Codable {

    /** Last week&#x27;s victory points gained by members of the given corporation */
    public var lastWeek: Int
    /** Total victory points gained since the given corporation enlisted */
    public var total: Int
    /** Yesterday&#x27;s victory points gained by members of the given corporation */
    public var yesterday: Int

    public init(lastWeek: Int, total: Int, yesterday: Int) {
        self.lastWeek = lastWeek
        self.total = total
        self.yesterday = yesterday
    }

    public enum CodingKeys: String, CodingKey { 
        case lastWeek = "last_week"
        case total
        case yesterday
    }

}
