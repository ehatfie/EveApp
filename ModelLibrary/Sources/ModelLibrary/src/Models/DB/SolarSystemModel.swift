//
//  SolarSystemModel.swift
//  ModelLibrary
//
//  Created by Erik Hatfield on 9/11/24.
//


import Foundation
import FluentSQLiteDriver

final public class SolarSystemModel: Model, @unchecked Sendable {
    static public let schema = Schemas.Universe.solarSystems.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Field(key: "constellation_id") public var constellationID: Int64
    @Field(key: "name") public var name: String
    @Field(key: "security_class") public var securityClass: String?
    @Field(key: "security_status") public var securityStatus: Float
    @Field(key: "star_id") public var starID: Int64?
    @Field(key: "system_id") public var systemID: Int64
    
    public init() { }
    
    public init(
        constellationID: Int64,
        name: String,
        securityClass: String?,
        securityStatus: Float,
        starID: Int64?,
        systemID: Int64
    ) {
        self.constellationID = constellationID
        self.name = name
        self.securityClass = securityClass
        self.securityStatus = securityStatus
        self.starID = starID
        self.systemID = systemID
    }
    
    public convenience init(data: GetUniverseSystemsSystemIdOk) {
        self.init(
            constellationID: Int64(data.constellationId),
            name: data.name,
            securityClass: data.securityClass,
            securityStatus: data.securityStatus,
            starID: Int64(data.starId ?? -1),
            systemID: Int64(data.systemId)
        )
    }
    
    public struct ModelMigration: AsyncMigration {
        public init() { }
        public func prepare(on database: Database) async throws {
            try await database.schema(SolarSystemModel.schema)
                .id()
                .field("constellation_id", .int64, .required)
                .field("name", .string, .required)
                .field("security_class", .string)
                .field("security_status", .float, .required)
                .field("star_id", .int64)
                .field("system_id", .int64, .required)
                .create()
        }
        
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(SolarSystemModel.schema)
                .delete()
        }
    }
}
