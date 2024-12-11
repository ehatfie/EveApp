//
//  DBManager+loading2.swift
//  EveApp
//
//  Created by Erik Hatfield on 5/28/24.
//

import Foundation
import Foundation
import Yams
import Fluent

extension DBManager {
  
  func readYamlAsync2<T: Decodable>(for fileName: YamlFiles, type: T.Type, splits: Int = 2) async throws -> [(Int64, T)] {
    guard let path = Bundle.main.path(forResource: fileName.rawValue, ofType: "yaml") else {
      throw NSError(domain: "", code: 0)
    }
    
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    let yaml = String(data: data, encoding: .utf8)!
    
    let node = try Yams.compose(yaml: yaml)!
    
    return await decodeNodeAsync(node: node, type: T.self, splits: splits)
  }
  
  func decodeNodeAsync<T: Decodable>(node: Yams.Node, type: T.Type, splits: Int = 2) async -> [(Int64, T)] {
    guard let mapping = node.mapping else {
      print("NO MAPPING")
      return []
    }
    let keyValuePair = mapping.map { $0 }
    
    let start = Date()
    
    let values = await withTaskGroup(of: [(Int64, T)].self, returning: [(Int64, T)].self) { taskGroup in
      var returnValues = [(Int64, T)]()
      
      taskGroup.addTask { await self.splitAndSortAsync(splits: splits, some: keyValuePair, type: type) }
      
      for await result in taskGroup {
        returnValues.append(contentsOf: result)
      }
      
      return returnValues
    }
   
    print("decodeNodeAsync() - splitAndSortAsync done \(Date().timeIntervalSince(start))")

    return values
  }
  
  func splitAndSortAsync<T: Decodable>(splits: Int, some: [Node.Mapping.Element], type: T.Type) async -> [(Int64, T)] {
    let keyValueCount = some.count
    
    let one = Array(some[0 ..< keyValueCount / 2])
    let two = Array(some[keyValueCount / 2 ..< keyValueCount])
    
    guard splits > 0 else {
      return await decode2(splits: 0, some: some, type: type)
    }
    
    let values = await withTaskGroup(of: [(Int64,T)].self, returning: [(Int64,T)].self) { taskGroup in
      var returnValues = [(Int64, T)]()
      
      taskGroup.addTask { await self.splitAndSortAsync(splits: splits - 1, some: one, type: type) }
      taskGroup.addTask { await self.splitAndSortAsync(splits: splits - 1, some: two, type: type) }
      
      for await result in taskGroup {
        returnValues.append(contentsOf: result)
      }
      
      return returnValues
    }
    return values
    //return await firstThing + secondThing
  }
}


/**
 
 /**
  let images = await withTaskGroup(of: UIImage.self, returning: [UIImage].self) { taskGroup in
  let photoURLs = await listPhotoURLs(inGallery: "Amsterdam Holiday")
  for photoURL in photoURLs {
  taskGroup.addTask { await downloadPhoto(url: photoURL) }
  }
  
  var images = [UIImage]()
  for await result in taskGroup {
  images.append(result)
  }
  return images
  }
  */
 let things = await withTaskGroup(of: T.self) { taskGroup in
 taskGroup.addTask {
 await splitAndSort(splits: splits - 1, some: one, type: type)
 }
 }
 */
