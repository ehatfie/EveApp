//
//  GetCharactersIndustryJobsResponse.swift
//  EveApp
//
//  Created by Erik Hatfield on 11/24/23.
//

import Foundation

public struct GetCharactersIndustryJobsResponse: Codable {

    public enum Status: String, Codable {
        case active = "active"
        case cancelled = "cancelled"
        case delivered = "delivered"
        case paused = "paused"
        case ready = "ready"
        case reverted = "reverted"
    }
    /** Job activity ID */
    public var activityId: Int
    /** blueprint_id integer */
    public var blueprintId: Int64
    /** Location ID of the location from which the blueprint was installed. Normally a station ID, but can also be an asset (e.g. container) or corporation facility */
    public var blueprintLocationId: Int64
    /** blueprint_type_id integer */
    public var blueprintTypeId: Int
    /** ID of the character which completed this job */
    public var completedCharacterId: Int?
    /** Date and time when this job was completed */
    public var completedDate: String?
    /** The sume of job installation fee and industry facility tax */
    public var cost: Double?
    /** Job duration in seconds */
    public var duration: Int
    /** Date and time when this job finished */
    public var endDate: String
    /** ID of the facility where this job is running */
    public var facilityId: Int64
    /** ID of the character which installed this job */
    public var installerId: Int
    /** Unique job ID */
    public var jobId: Int
    /** Number of runs blueprint is licensed for */
    public var licensedRuns: Int?
    /** Location ID of the location to which the output of the job will be delivered. Normally a station ID, but can also be a corporation facility */
    public var outputLocationId: Int64
    /** Date and time when this job was paused (i.e. time when the facility where this job was installed went offline) */
    public var pauseDate: String?
    /** Chance of success for invention */
    public var probability: Float?
    /** Type ID of product (manufactured, copied or invented) */
    public var productTypeId: Int?
    /** Number of runs for a manufacturing job, or number of copies to make for a blueprint copy */
    public var runs: Int
    /** Date and time when this job started */
    public var startDate: String
    /** ID of the station where industry facility is located */
    public var stationId: Int64
    /** status string */
    public var status: Status
    /** Number of successful runs for this job. Equal to runs unless this is an invention job */
    public var successfulRuns: Int?

    public init(activityId: Int, blueprintId: Int64, blueprintLocationId: Int64, blueprintTypeId: Int, completedCharacterId: Int? = nil, completedDate: String? = nil, cost: Double? = nil, duration: Int, endDate: String, facilityId: Int64, installerId: Int, jobId: Int, licensedRuns: Int? = nil, outputLocationId: Int64, pauseDate: String? = nil, probability: Float? = nil, productTypeId: Int? = nil, runs: Int, startDate: String, stationId: Int64, status: Status, successfulRuns: Int? = nil) {
        self.activityId = activityId
        self.blueprintId = blueprintId
        self.blueprintLocationId = blueprintLocationId
        self.blueprintTypeId = blueprintTypeId
        self.completedCharacterId = completedCharacterId
        self.completedDate = completedDate
        self.cost = cost
        self.duration = duration
        self.endDate = endDate
        self.facilityId = facilityId
        self.installerId = installerId
        self.jobId = jobId
        self.licensedRuns = licensedRuns
        self.outputLocationId = outputLocationId
        self.pauseDate = pauseDate
        self.probability = probability
        self.productTypeId = productTypeId
        self.runs = runs
        self.startDate = startDate
        self.stationId = stationId
        self.status = status
        self.successfulRuns = successfulRuns
    }
    
    public init() {
        self.init(
            activityId: 0,
            blueprintId: 0,
            blueprintLocationId: 0,
            blueprintTypeId: 0,
            duration: 0,
            endDate: "",
            facilityId: 0,
            installerId: 0,
            jobId: 0,
            outputLocationId: 0,
            runs: 0,
            startDate: "",
            stationId: 0,
            status: .active
        )
    }

    public enum CodingKeys: String, CodingKey {
        case activityId = "activity_id"
        case blueprintId = "blueprint_id"
        case blueprintLocationId = "blueprint_location_id"
        case blueprintTypeId = "blueprint_type_id"
        case completedCharacterId = "completed_character_id"
        case completedDate = "completed_date"
        case cost
        case duration
        case endDate = "end_date"
        case facilityId = "facility_id"
        case installerId = "installer_id"
        case jobId = "job_id"
        case licensedRuns = "licensed_runs"
        case outputLocationId = "output_location_id"
        case pauseDate = "pause_date"
        case probability
        case productTypeId = "product_type_id"
        case runs
        case startDate = "start_date"
        case stationId = "station_id"
        case status
        case successfulRuns = "successful_runs"
    }

}
