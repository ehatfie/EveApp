//
//  DogmaAttributeCategoryModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Fluent
import Vapor

final public class DogmaAttributeCategoryModel: Model, Content, @unchecked Sendable {
    static public let schema = "DogmaAttributeCategoryModel"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "category_id")
    public var categoryId: Int64
    
    @Field(key: "category_description")
    public var categoryDescription: String
    
    @Field(key: "name")
    public var name: String
    
    public init() { }
    
    public init(categoryId: Int64, data: TypeDogmaAttributeCategoryData) {
        self.id = UUID()
        self.categoryId = categoryId
        self.categoryDescription = data.description ?? ""
        self.name = data.name
    }
}

public struct CreateDogmaAttributeCategoryModelMigration: Migration {
    public init() { }
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(DogmaAttributeCategoryModel.schema)
            .id()
            .field("category_id", .int64)
            .field("category_description", .string)
            .field("name", .string)
            .create()
    }
  
  public func revert(on database: Database) -> EventLoopFuture<Void> {
      database.schema(DogmaAttributeCategoryModel.schema).delete()
  }
}

public struct TypeDogmaAttributeCategoryData: Codable {
    let description: String?
    let name: String
}

