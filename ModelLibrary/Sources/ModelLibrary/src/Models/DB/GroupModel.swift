//
//  GroupModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Foundation
import FluentSQLiteDriver

public struct GroupData: Codable {
    public let anchorable: Bool
    public let anchored: Bool
    public let categoryID: Int64
    public let fittableNonSingleton: Bool
    public let name: ThingName
    public let published: Bool
    public let useBasePrice: Bool
    
    public init(id: Int64, name: String) {
        self.init(
            anchorable: true,
            anchored: true,
            categoryID: id,
            fittableNonSingleton: true,
            name: ThingName(name: name),
            published: true,
            useBasePrice: true)
    }
    
    public init(anchorable: Bool,
        anchored: Bool,
        categoryID: Int64,
        fittableNonSingleton: Bool,
        name: ThingName,
        published: Bool,
        useBasePrice: Bool
    ) {
        self.anchorable = anchorable
        self.anchored = anchored
        self.categoryID = categoryID
        self.fittableNonSingleton = fittableNonSingleton
        self.name = name
        self.published = published
        self.useBasePrice = useBasePrice
    }
}

final public class GroupModel: Model, @unchecked Sendable {
    public static let schema = Schemas.groups.rawValue
    @ID(key: .id) public var id: UUID?
    
    //@Parent(key: "categoryModel")var categoryModel: CategoryModel
    
    @Field(key: "group_id") public var groupId: Int64
    @Field(key: "anchorable") public var anchorable: Bool
    @Field(key: "anchored") public var anchored: Bool
    @Field(key: "category_id") public var categoryID: Int64
    @Field(key: "fittable_non_singleton") public var fittableNonSingleton: Bool
    @Field(key: "name") public var name: String
    @Field(key: "published") public var published: Bool
    @Field(key: "use_base_price") public var useBasePrice: Bool
    
    
    //var category: ThingCategory?
    
    //var typeData: [ThingType]?
    
    public init() { }
    
    public init(groupId: Int64, groupData: GroupData) {
        self.id = UUID()
        self.groupId = groupId
        self.anchorable = groupData.anchorable
        self.anchored = groupData.anchored
        self.categoryID = groupData.categoryID
        self.fittableNonSingleton = groupData.fittableNonSingleton
        self.name = groupData.name.en ?? ""
        self.published = groupData.published
        self.useBasePrice = groupData.useBasePrice
    }
}

public struct CreateGroupModelMigration: Migration {
    public init() { }
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(GroupModel.schema)
            .id()
            .field("group_id", .int64)
            .field("anchorable", .bool)
            .field("anchored", .bool)
            .field("category_id", .int64)
            .field("fittable_non_singleton", .bool)
            .field("name", .string)
            .field("published", .bool)
            .field("use_base_price", .bool)
            .create()
            //.field("categoryModel", .uuid, .required, .references(Schemas.categories.rawValue, "id"))
    }
    
    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(GroupModel.schema).delete()
    }
}

extension GroupModel: Equatable, Hashable {
  static public func == (lhs: GroupModel, rhs: GroupModel) -> Bool {
    lhs.groupId < rhs.groupId
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(groupId)
    //hasher.combine(label)
    //hasher.combine(command)
  }
}
