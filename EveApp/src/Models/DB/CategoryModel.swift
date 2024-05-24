//
//  CategoryModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Foundation
import FluentSQLiteDriver

enum Schemas: String {
    case categories = "categories"
    case groups = "groups"
    case dogmaEffect = "dogmaEffect"
    case dogmaAttribute = "dogmaAttribute"
    case typeDogma = "typeDogma"
    case typeDogmaInfo = "typeDogmaInfo"
    case typeDogmaAttributeInfo = "typeDogmaAttributeInfo"
    case typeDogmaEffectInfo = "typeDogmaEffectInfo"
    case materialDataModel = "materialDataModel"
    case typeMaterialsModel = "typeMaterialsModel"
    case blueprintModel = "blueprintModel"
    case raceModel = "raceModel"
    
    case characterDataModel = "characterDataModel"
    case characterPublicDataModel = "characterPublicDataModel"
    case characterAssetsDataModel = "characterAssetsDataModel"
}

final class CategoryModel: Model {
    static let schema = Schemas.categories.rawValue
    
    @ID(key: .id) var id: UUID?
    
    @Field(key: "categoryId") var categoryId: Int64
    @Field(key: "name") var name: String
    @Field(key: "published") var published: Bool
    
    //@Children(for: \.$categoryModel) var groups: [GroupModel]
    
    init() { }
    
    init(id: Int64, data: CategoryData) {
        self.id = UUID()
        self.categoryId = id
        self.name = data.name.en ?? ""
        self.published = data.published
    }
}

struct CreateCategoryModelMigration: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    database.schema(CategoryModel.schema)
      .id()
      .field("categoryId", .int64, .required)
      .field("name", .string, .required)
      .field("published",.bool, .required)
      .create()
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(CategoryModel.schema)
      .delete()
  }
}
