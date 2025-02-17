//
//  MarketGroupModel.swift
//  ModelLibrary
//
//  Created by Erik Hatfield on 2/14/25.
//

import Foundation
import Fluent



/*
 public struct GetMarketsGroupsMarketGroupIdOk: Codable {
 
     /** description string */
     public var _description: String
     /** market_group_id integer */
     public var marketGroupId: Int
     /** name string */
     public var name: String
     /** parent_group_id integer */
     public var parentGroupId: Int?
     /** types array */
     public var types: [Int]
     
     public init(_description: String, marketGroupId: Int, name: String, parentGroupId: Int? = nil, types: [Int]) {
     self._description = _description
     self.marketGroupId = marketGroupId
     self.name = name
     self.parentGroupId = parentGroupId
     self.types = types
     }
     
     public enum CodingKeys: String, CodingKey {
     case _description = "description"
     case marketGroupId = "market_group_id"
     case name
     case parentGroupId = "parent_group_id"
     case types
     }
 
 }
 */



public struct MarketGroupIdOk: Codable {

    /** description string */
    public var descriptionID: ThingName?
    public var hasTypes: Bool
    public var iconID: Int
    /** name string */
    public var nameID: ThingName
    /** parent_group_id integer */
    public var parentGroupID: Int?


    public init(
        descriptionID: ThingName?,
        hasTypes: Bool,
        iconID: Int,
        nameID: ThingName,
        parentGroupID: Int? = nil
    ) {
        self.descriptionID = descriptionID
        self.hasTypes = hasTypes
        self.iconID = iconID
        self.nameID = nameID
        self.parentGroupID = parentGroupID
    }

//    public enum CodingKeys: String, CodingKey {
//        case _description = "description"
//        case marketGroupId = "market_group_id"
//        case name
//        case parentGroupId = "parent_group_id"
//        case types
//    }

}


final public class MarketGroupModel: Model, @unchecked Sendable {
    static public let schema = Schemas.marketGroupModel.rawValue
    
    @ID(key: .id) public var id: UUID?
    
    @Field(key: "groupDescription") public var groupDescription: String
    @Field(key: "hasTypes") public var hasTypes: Bool
    @Field(key: "iconID") public var iconID: Int
    @Field(key: "marketGroupId") public var marketGroupId: Int
    @Field(key: "name") public var name: String
    @Field(key: "parentGroupId") public var parentGroupId: Int?

    
    public init() { }
    
    public init(
        groupDescription: String,
        hasTypes: Bool,
        iconID: Int,
        marketGroupId: Int,
        name: String,
        parentGroupId: Int? = nil
    ) {
        self.groupDescription = groupDescription
        self.hasTypes = hasTypes
        self.iconID = iconID
        self.marketGroupId = marketGroupId
        self.name = name
        self.parentGroupId = parentGroupId
    }
    
    public convenience init(from model: MarketGroupIdOk, marketGroupId: Int) {
        self.init(
            groupDescription: model.descriptionID?.en ?? "",
            hasTypes: model.hasTypes,
            iconID: model.iconID,
            marketGroupId: marketGroupId,
            name: model.nameID.en ?? "",
            parentGroupId: model.parentGroupID
        )
    }
    
    public struct ModelMigration: AsyncMigration {
        public init() {}
        
        public func prepare(on database: FluentKit.Database) async throws {
            try await database.schema(MarketGroupModel.schema)
                .id()
                .field("groupDescription", .string, .required)
                .field("hasTypes", .bool, .required)
                .field("iconID", .int, .required)
                .field("marketGroupId", .int, .required)
                .field("name", .string, .required)
                .field("parentGroupId", .int)
                .create()
        }
        
        public func revert(on database: any FluentKit.Database) async throws {
            try await database.schema(MarketGroupModel.schema)
                .delete()
        }
    }
}
