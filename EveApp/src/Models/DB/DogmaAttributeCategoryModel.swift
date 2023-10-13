//
//  DogmaAttributeCategoryModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Fluent
import Vapor

final class DogmaAttributeCategoryModel: Model, Content {
    static let schema = "DogmaAttributeCategoryModel"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "categoryId")
    var categoryId: Int64
    
    @Field(key: "categoryDescription")
    var categoryDescription: String
    
    @Field(key: "name")
    var name: String
    
    init() { }
    
    init(categoryId: Int64, data: TypeDogmaAttributeCategoryData) {
        self.id = UUID()
        self.categoryId = categoryId
        self.categoryDescription = data.description ?? ""
        self.name = data.name
    }
}

struct CreateDogmaAttributeCategoryModelMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DogmaAttributeCategoryModel.schema)
            .id()
            .field("categoryId", .string)
            .field("categoryDescription", .string)
            .field("name", .string)
            .create()
    }
  
  func revert(on database: Database) -> EventLoopFuture<Void> {
      database.schema(DogmaAttributeCategoryModel.schema).delete()
  }
}


struct TypeDogmaAttributeCategoryData: Codable {
    let description: String?
    let name: String
}
