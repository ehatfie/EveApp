//
//  CharacterIndustryJob.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/7/24.
//

import FluentSQLiteDriver
import Foundation

final public class CharacterIndustryJobModel: Model {
    static public let schema = Schemas.characterIndustryJobModel.rawValue

    public enum Status: String, Codable {
        case active = "active"
        case cancelled = "cancelled"
        case delivered = "delivered"
        case paused = "paused"
        case ready = "ready"
        case reverted = "reverted"
    }
    
    @ID(key: .id) public var id: UUID?
    
    @Parent(key: "characterId")
    public var characterDataModel: CharacterDataModel

    @Field(key: "activityID")
    public var activityId: Int

    @Field(key: "blueprintID")
    public var blueprintId: Int64

    @Field(key: "blueprintLocationID")
    public var blueprintLocationId: Int64

    @Field(key: "blueprintTypeID")
    public var blueprintTypeId: Int64

    @Field(key: "completedCharacterID")
    public var completedCharacterId: Int?

    @Field(key: "completedDate")
    public var completedDate: String?
    
    @Field(key: "cost")
    public var cost: Double?
    
    @Field(key: "duration")
    public var duration: Int
    
    @Field(key: "endDate")
    public var endDate: String
    
    @Field(key: "facilityID")
    public var facilityId: Int64
    
    @Field(key: "installerID")
    public var installerId: Int64
    
    @Field(key: "jobID")
    public var jobId: Int
    
    @Field(key: "licensedRuns")
    public var licensedRuns: Int?
    
    @Field(key: "outputLocationID")
    public var outputLocationId: Int64
    
    @Field(key: "pauseDate")
    public var pauseDate: String?
    
    @Field(key: "probability")
    public var probability: Float?
    
    @Field(key: "productTypeID")
    public var productTypeId: Int64?
    
    @Field(key: "runs")
    public var runs: Int
    
    @Field(key: "startDate")
    public var startDate: String
    
    @Field(key: "stationID")
    public var stationId: Int64
    
    @Field(key: "status")
    public var status: Status
    
    @Field(key: "successfulRuns")
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
                .field(
                    "characterId",
                    .uuid,
                    .required,
                    .references(Schemas.characterDataModel.rawValue, "id")
                )
                .field("activityID", .int, .required)
                .field("blueprintID", .int64, .required)
                .field("blueprintLocationID", .int64, .required)
                .field("blueprintTypeID", .int64, .required)
                .field("completedCharacterID", .int)
                .field("completedDate", .string)
                .field("cost", .double)
                .field("duration", .int, .required)
                .field("endDate", .string, .required)
                .field("facilityID", .int64, .required)
                .field("installerID", .int64, .required)
                .field("jobID", .int, .required)
                .field("licensedRuns", .int)
                .field("outputLocationID", .int64, .required)
                .field("pauseDate", .string)
                .field("probability", .float)
                .field("productTypeID", .int64)
                .field("runs", .int, .required)
                .field("startDate", .string, .required)
                .field("stationID", .int64, .required)
                .field("status", .string, .required)
                .field("successfulRuns", .int)
                .create()
        }

        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(CharacterIndustryJobModel.schema)
                .delete()
        }
    }

}
