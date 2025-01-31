//
//  CharacterIndustryJob.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/7/24.
//

import FluentSQLiteDriver
import Foundation

final public class CharacterIndustryJobModel: Model, @unchecked Sendable {
    static public let schema = Schemas.characterIndustryJobModel.rawValue

    public enum Status: String, Codable, Sendable {
        case active = "active"
        case cancelled = "cancelled"
        case delivered = "delivered"
        case paused = "paused"
        case ready = "ready"
        case reverted = "reverted"
    }
    
    @ID(custom: "character_industry_job_id", generatedBy: .user)
    public var id: Int?
    
    @Parent(key: "character_id")
    public var characterDataModel: CharacterDataModel

    @Field(key: "activity_id")
    public var activityId: Int

    @Field(key: "blueprint_id")
    public var blueprintId: Int64

    @Field(key: "blueprint_location_id")
    public var blueprintLocationId: Int64

    @Field(key: "blueprint_type_id")
    public var blueprintTypeId: Int64

    @Field(key: "completed_character_id")
    public var completedCharacterId: Int?

    @Field(key: "completed_date")
    public var completedDate: String?
    
    @Field(key: "cost")
    public var cost: Double?
    
    @Field(key: "duration")
    public var duration: Int
    
    @Field(key: "end_date")
    public var endDate: String
    
    @Field(key: "facility_id")
    public var facilityId: Int64
    
    @Field(key: "installer_id")
    public var installerId: Int64
    
    @Field(key: "job_id")
    public var jobId: Int
    
    @Field(key: "licensed_runs")
    public var licensedRuns: Int?
    
    @Field(key: "output_location_id")
    public var outputLocationId: Int64
    
    @Field(key: "pause_date")
    public var pauseDate: String?
    
    @Field(key: "probability")
    public var probability: Float?
    
    @Field(key: "product_type_id")
    public var productTypeId: Int64?
    
    @Field(key: "runs")
    public var runs: Int
    
    @Field(key: "start_date")
    public var startDate: String
    
    @Field(key: "station_id")
    public var stationId: Int64
    
    @Field(key: "status")
    public var status: Status
    
    @Field(key: "successful_runs")
    public var successfulRuns: Int?

    public init() {}

    public init(
        activityId: Int,
        blueprintId: Int64,
        blueprintLocationId: Int64,
        blueprintTypeId: Int64,
        completedCharacterId: Int? = nil,
        completedDate: String? = nil,
        cost: Double? = nil,
        duration: Int,
        endDate: String,
        facilityId: Int64,
        installerId: Int64,
        jobId: Int,
        licensedRuns: Int? = nil,
        outputLocationId: Int64,
        pauseDate: String? = nil,
        probability: Float? = nil,
        productTypeId: Int64? = nil,
        runs: Int,
        startDate: String,
        stationId: Int64,
        status: Status,
        successfulRuns: Int? = nil
    ) {
        self.id = jobId
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

    public convenience init(
        characterId: String,
        data: GetCharactersIndustryJobsResponse
    ) {
        let status: Status
        
        switch data.status {
        case .active:
            status = .active
        case .cancelled:
            status = .cancelled
        case .delivered:
            status = .delivered
        case .paused:
            status = .paused
        case .ready:
            status = .ready
        case .reverted:
            status = .reverted
        }
        
        var productTypeId: Int64? = nil
        if let unwrapped = data.productTypeId {
            productTypeId = Int64(unwrapped)
        }
        
        self.init(
            activityId: data.activityId,
            blueprintId: data.blueprintId,
            blueprintLocationId: data.blueprintLocationId,
            blueprintTypeId: Int64(data.blueprintTypeId),
            completedCharacterId: data.completedCharacterId,
            completedDate: data.completedDate,
            cost: data.cost,
            duration: data.duration,
            endDate: data.endDate,
            facilityId: data.facilityId,
            installerId: Int64(data.installerId),
            jobId: data.jobId,
            licensedRuns: data.licensedRuns,
            outputLocationId: data.outputLocationId,
            pauseDate: data.pauseDate,
            probability: data.probability,
            productTypeId: productTypeId,
            runs: data.runs,
            startDate: data.startDate,
            stationId: data.stationId,
            status: status,
            successfulRuns: data.successfulRuns
        )
    }
}

extension CharacterIndustryJobModel {
    
    public struct ModelMigration: AsyncMigration {
        public init() { }
        public func prepare(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterIndustryJobModel.schema)
                .id()
                .field("character_industry_job_id", .int)
                .field(
                    "character_id",
                    .uuid,
                    .required,
                    .references(Schemas.characterDataModel.rawValue, "id")
                )
                .field("activity_id", .int, .required)
                .field("blueprint_id", .int64, .required)
                .field("blueprint_location_id", .int64, .required)
                .field("blueprint_type_id", .int64, .required)
                .field("completed_character_id", .int)
                .field("completed_date", .string)
                .field("cost", .double)
                .field("duration", .int, .required)
                .field("end_date", .string, .required)
                .field("facility_id", .int64, .required)
                .field("installer_id", .int64, .required)
                .field("job_id", .int, .required)
                .field("licensed_runs", .int)
                .field("output_location_id", .int64, .required)
                .field("pause_date", .string)
                .field("probability", .float)
                .field("product_type_id", .int64)
                .field("runs", .int, .required)
                .field("start_date", .string, .required)
                .field("station_id", .int64, .required)
                .field("status", .string, .required)
                .field("successful_runs", .int)
                .unique(on: "character_industry_job_id")
                .create()
        }

        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterIndustryJobModel.schema)
                .delete()
        }
    }

}
