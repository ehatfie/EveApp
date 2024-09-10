//
//  CategoryModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import FluentSQLiteDriver
import Foundation

public struct CategoryData: Codable {
    public let name: ThingName
    public let published: Bool

    public init(name: ThingName, published: Bool) {
        self.name = name
        self.published = published
    }
}

public final class CategoryModel: Model {
    public static let schema = Schemas.categories.rawValue

    @ID(key: .id) public var id: UUID?

    @Field(key: "categoryId") public var categoryId: Int64
    @Field(key: "name") public var name: String
    @Field(key: "published") public var published: Bool

    //@Children(for: \.$categoryModel) var groups: [GroupModel]

    public init() {}

    public init(id: Int64, data: CategoryData) {
        self.id = UUID()
        self.categoryId = id
        self.name = data.name.en ?? ""
        self.published = data.published
    }
}

public struct CreateCategoryModelMigration: Migration {

    public init() {}
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(CategoryModel.schema)
            .id()
            .field("categoryId", .int64, .required)
            .field("name", .string, .required)
            .field("published", .bool, .required)
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(CategoryModel.schema)
            .delete()
    }
}

extension CategoryModel: Equatable, Hashable {
    public static func == (lhs: CategoryModel, rhs: CategoryModel) -> Bool {
        lhs.categoryId < rhs.categoryId
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(categoryId)
        //hasher.combine(label)
        //hasher.combine(command)
    }
}
