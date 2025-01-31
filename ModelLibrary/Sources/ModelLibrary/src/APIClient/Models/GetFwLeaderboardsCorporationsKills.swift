//
// GetFwLeaderboardsCorporationsKills.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** Top 10 rankings of corporations by number of kills from yesterday, last week and in total */

public struct GetFwLeaderboardsCorporationsKills: Codable {

    /** Top 10 ranking of corporations active in faction warfare by total kills. A corporation is considered \&quot;active\&quot; if they have participated in faction warfare in the past 14 days */
    public var activeTotal: [GetFwLeaderboardsCorporationsActiveTotalActiveTotal]
    /** Top 10 ranking of corporations by kills in the past week */
    public var lastWeek: [GetFwLeaderboardsCorporationsLastWeekLastWeek]
    /** Top 10 ranking of corporations by kills in the past day */
    public var yesterday: [GetFwLeaderboardsCorporationsYesterdayYesterday]

    public init(activeTotal: [GetFwLeaderboardsCorporationsActiveTotalActiveTotal], lastWeek: [GetFwLeaderboardsCorporationsLastWeekLastWeek], yesterday: [GetFwLeaderboardsCorporationsYesterdayYesterday]) {
        self.activeTotal = activeTotal
        self.lastWeek = lastWeek
        self.yesterday = yesterday
    }

    public enum CodingKeys: String, CodingKey { 
        case activeTotal = "active_total"
        case lastWeek = "last_week"
        case yesterday
    }

}
