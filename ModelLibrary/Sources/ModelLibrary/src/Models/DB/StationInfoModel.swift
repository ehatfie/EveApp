//
//  StationInfoModel.swift
//  ModelLibrary
//
//  Created by Erik Hatfield on 6/14/25.
//

import Fluent

public struct GetStructureInfoResponse: Codable, Sendable {
    public let stationId: Int64
    public let response: GetUniverseStructuresStructureIdOk
    
    public init(stationId: Int64, response: GetUniverseStructuresStructureIdOk) {
        self.stationId = stationId
        self.response = response
    }
}

final public class StationInfoModel: @unchecked Sendable, Model {
    public static let schema = Schemas.stationInfo.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Field(key: "name") public var name: String
    @Field(key: "owner") public var owner: Int?
    @Field(key: "station_id") public var stationId: Int64
    @Field(key: "system_id") public var systemId: Int64
    @Field(key: "type_id") public var typeId: Int64
    @Field(key: "reprocessing_efficiency") public var reprocessingEfficiency: Float // can be optional
    @Field(key: "reprocessing_stations_take") public var reprocessingStationsTake: Float // can be optional
    
    public init() {}
    
    public convenience init(from3 data: GetStructureInfoResponse, id: UUID? = UUID()) {
        self.init(from2: data.response, stationId: data.stationId, id: id)
    }
    
    public init(from data: GetStationInfoResponse, id: UUID? = UUID()) {
        self.id = id
        self.name = data.name
        self.owner = data.owner
        self.stationId = Int64(data.stationId)
        self.systemId = Int64(data.systemId)
        self.typeId = Int64(data.typeId)
        self.reprocessingEfficiency = data.reprocessingEfficiency
        self.reprocessingStationsTake = data.reprocessingStationsTake
    }
    
    public init(from2 data: GetUniverseStructuresStructureIdOk, stationId: Int64, id: UUID? = UUID()) {
        self.id = id
        self.name = data.name
        self.owner = data.ownerId
        self.stationId = stationId
        self.systemId = Int64(data.solarSystemId)
        self.typeId = Int64(data.typeId ?? 0)
        self.reprocessingEfficiency = 0.0
        self.reprocessingStationsTake = 0.0
    }
    
    public struct ModelMigration: AsyncMigration {
        public init() { }
        
        public func prepare(on database: Database) async throws {
            try await database.schema(StationInfoModel.schema)
                .id()
                .field("name", .string, .required)
                .field("owner", .int)
                .field("station_id", .int64, .required)
                .field("system_id", .int64, .required)
                .field("type_id", .int64, .required)
                .field("reprocessing_efficiency", .float, .required)
                .field("reprocessing_stations_take", .float, .required)
                .unique(on: "station_id")
                .create()
        }
        
        public func revert(on database: Database) async throws {
            try await database.schema(StationInfoModel.schema).delete()
        }
    }
}
