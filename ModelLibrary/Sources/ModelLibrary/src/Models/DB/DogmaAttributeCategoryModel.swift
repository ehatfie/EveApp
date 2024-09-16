//
//  DogmaAttributeCategoryModel.swift
//  EveApp
//
//  Created by Erik Hatfield on 9/30/23.
//

import Fluent
import Vapor

final public class DogmaAttributeCategoryModel: Model, Content {
    static public let schema = "DogmaAttributeCategoryModel"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: "categoryId")
    public var categoryId: Int64
    
    @Field(key: "categoryDescription")
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
            .field("categoryId", .int64)
            .field("categoryDescription", .string)
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
