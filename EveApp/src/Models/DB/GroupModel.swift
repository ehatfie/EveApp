//
//  GroupModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Foundation
import FluentSQLiteDriver

struct GroupData: Codable {
    let anchorable: Bool
    let anchored: Bool
    let categoryID: Int64
    let fittableNonSingleton: Bool
    let name: ThingName
    let published: Bool
    let useBasePrice: Bool
    
    init(id: Int64, name: String) {
        self.init(
            anchorable: true,
            anchored: true,
            categoryID: id,
            fittableNonSingleton: true,
            name: ThingName(name: name),
            published: true,
            useBasePrice: true)
    }
    
    init(anchorable: Bool,
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

final class GroupModel: Model {
    static let schema = Schemas.groups.rawValue
    @ID(key: .id) var id: UUID?
    
    //@Parent(key: "categoryModel")var categoryModel: CategoryModel
    
    @Field(key: "groupId") var groupId: Int64
    @Field(key: "anchorable") var anchorable: Bool
    @Field(key: "anchored") var anchored: Bool
    @Field(key: "categoryId") var categoryID: Int64
    @Field(key: "fittableNonSingleton") var fittableNonSingleton: Bool
    @Field(key: "name") var name: String
    @Field(key: "published") var published: Bool
    @Field(key: "useBasePrice") var useBasePrice: Bool
    
    
    //var category: ThingCategory?
    
    //var typeData: [ThingType]?
    
    init() { }
    
    init(groupId: Int64, groupData: GroupData) {
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

struct CreateGroupModelMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(GroupModel.schema)
            .id()
            .field("groupId", .bool)
            .field("anchorable", .bool)
            .field("anchored", .bool)
            .field("categoryId", .int64)
            .field("fittableNonSingleton", .bool)
            .field("name", .string)
            .field("published", .bool)
            .field("useBasePrice", .bool)
            .create()
            //.field("categoryModel", .uuid, .required, .references(Schemas.categories.rawValue, "id"))
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(GroupModel.schema).delete()
    }
}
