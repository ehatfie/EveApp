//
//  RaceModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 12/17/23.
//

import FluentKit
import Foundation

public struct RaceData: Codable {
    public let descriptionID: ThingName?
    public let iconID: Int64?
    public let nameID: ThingName
    public let shipTypeID: Int64?
}

final public class RaceModel: Model, @unchecked Sendable {
    static public let schema = Schemas.raceModel.rawValue
    @ID(key: .id) public var id: UUID?

    @Field(key: "race_id") public var raceID: Int64
    @Field(key: "description_id") public var descriptionID: String
    @Field(key: "icon_id") public var iconID: Int64?
    @Field(key: "name_id") public var nameID: String
    @Field(key: "shipType_id") public var shipTypeID: Int64?

    public init() {}

    public init(raceID: Int64, raceData: RaceData) {
        self.id = UUID()
        self.raceID = raceID
        self.descriptionID = raceData.descriptionID?.en ?? ""
        self.iconID = raceData.iconID
        self.nameID = raceData.nameID.en ?? ""
        self.shipTypeID = raceData.shipTypeID
    }

    public struct ModelMigration: AsyncMigration {
        public init() {}
        public func prepare(on database: Database) async throws {
            try await database.schema(RaceModel.schema)
                .id()
                .field("race_id", .int64, .required)
                .field("description_id", .string, .required)
                .field("icon_id", .int64)
                .field("name_id", .string, .required)
                .field("shipType_id", .int64)
                .create()
        }

        public func revert(on database: Database) async throws {
            try await database.schema(RaceModel.schema).delete()
        }
    }
}
