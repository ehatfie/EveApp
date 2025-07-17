//
//  KMSyncManager.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/15/25.
//

import Foundation
import SwiftUI
import NIOPosix
import NIOCore
import NIOHTTP1
import NIOHTTP2
import AsyncHTTPClient
//import SwiftyRedis
//import RediStack

enum TestActions {
  case fetch
}

actor RedisActor1 {
    //private let client: RedisConnection
  private let eventLoopGroup: EventLoopGroup
  private let eventLoop: EventLoop

  var dataCallback: ((ZKillFeedResponseWrapper) -> Void)?
  let host = "https://zkillredisq.stream/listen.php?queueID=Volvvfdwtron900145"
  var last: Date = Date()
  
  var repeatedTask: RepeatedTask?
  
  init() {
    self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    self.eventLoop = eventLoopGroup.next()
    print("-- RedisActor init")
    //one()
  }

    init(host: String = "localhost", port: Int = 6379) async throws {
      self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
      self.eventLoop = eventLoopGroup.next()
      
      let host = "https://zkillredisq.stream/listen.php?queueID=Voltron9000"
//      let client = RedisConnection.make(
//        configuration: try .init(url: host),
//          boundEventLoop: eventLoopGroup.next()
//      )
//      
//      self.client = try await client.get()
      //try await setup()
      //one()
    }
  
  func setCallback(_ callback: @escaping (ZKillFeedResponseWrapper) -> Void) {
    self.dataCallback = callback
  }
  
  func start() {
    print("-- start")
    let returnCall = self.dataCallback
    let host = "https://zkillredisq.stream/listen.php?queueID=Volvvfdwtron90014"
    
    self.repeatedTask = eventLoop.scheduleRepeatedAsyncTask(initialDelay: .seconds(1), delay: .seconds(1)) { value in
      print("-- api call")
      let foo = HTTPClient.shared.get(url: host)
      return foo.map { value in
        print("-- got api respnose")
        guard let body = value.body else {
          return
        }
        do {
          let decoder = JSONDecoder()
          let data = Data(buffer: body, byteTransferStrategy: .automatic)
          let object = try decoder.decode(ZKillFeedResponseWrapper.self, from: data)
          // context.application.post
          
          //print("-- email job got \(object.package.killID) took \(Date().timeIntervalSince(self.last))")
          returnCall?(object)
          //retuself.dataCallback?(object)
        } catch let error {
          print("-- decode error \(error)")
        }
      }
      
//      HTTPClient.shared.get(url: "https://apple.com/").whenComplete { result in
//          switch result {
//          case .failure(let error):
//              // process error
//          case .success(let response):
//              if response.status == .ok {
//                  // handle response
//              } else {
//                  // handle remote error
//              }
//          }
//      }
    }
    
  }
  
  func shutdown() {
    do {
      self.repeatedTask?.cancel()
      self.repeatedTask = nil
      //eventLoop.cancelScheduledCallback(
    } catch let error {
      print("++ Shutdown error \(error)")
    }
    
    
//    eventLoop.shutdownGracefully { error in
//      if let error = error {
//        print("++ shutdownGracefully error \(error)")
//      }
//    }
  }
  
    func setup() async throws {
      print("-- redis setup")
      
      //try await doActionAsync(.fetch)
      while true {
        last = Date()
        try await fetchAsync()
      }
    }
  
  func doAction(_ action: TestActions) throws {
    print("-- doAction \(action)")
    switch action {
      case .fetch:
        last = Date()
        try fetch()
      try doAction(.fetch)
    }
  }
  
  func doActionAsync(_ action: TestActions) async throws {
    print("-- doAction \(action)")
    switch action {
      case .fetch:
        last = Date()
        try await fetchAsync()
      try await doActionAsync(.fetch)
      
    }
  }
  
  func fetch() throws {
    print("-- fetch ")
    do {
       
      //let task = URLSession.shared.dataTask(with: URL(string: host)!)
      //task.resume()
      
//      let (data, _) = try URLSession.shared.data(from: URL(string: host)!)
//      let decoder = JSONDecoder()
//      let object = try decoder.decode(ZKillFeedResponseWrapper.self, from: data)
//      // context.application.post
//      
//      print("-- email job got \(object.package.killID) took \(Date().timeIntervalSince(last))")
//      dataCallback?(object)
      //print("got object \(object)")
                
      print("-- got data")
    } catch let err {
      print("-- redis err \(err)")
    }
  }
  
  func fetchAsync() async throws {
    print("-- fetch ")
    do {
      let (data, _) = try await URLSession.shared.data(from: URL(string: host)!)
      let decoder = JSONDecoder()
      let object = try decoder.decode(ZKillFeedResponseWrapper.self, from: data)
      // context.application.post
      
      print("-- email job got \(object.package.killID) took \(Date().timeIntervalSince(last))")
      dataCallback?(object)
      //print("got object \(object)")
                
      print("-- got data")
    } catch let err {
      print("-- redis err \(err)")
    }
  }

    func set(key: String, value: String) async throws {
        //try await connection.set(key: key, value: value)
    }

    func get(key: String) async throws -> String? {
        //return try await connection.get(key: key)
      return nil
    }

    func close() {
//        connection.close()
//        group.shutdownGracefully { _ in }
    }
  
  
}

actor RedisActor {

  private var streamTask: Task<Void, Error>?
  let elg = MultiThreadedEventLoopGroup(numberOfThreads: 1)

  init() {
    
  }

  func startListening() async {

    do {
//      let client = RedisClient(.init("https://zkillredisq.stream/listen.php"))
//      let connection = try await client.getConnection()
//
//      let value: String = try await connection.hget("myhash", "field1")
//      
//      let (data, _) = try await URLSession.shared.data(from: url)
//
//      let decoder = JSONDecoder()
//      decoder.dateDecodingStrategy = .iso8601
//
//      let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
//      try decoder.decode(ZKillFeedResponse.self, from: jsonData)
//      
//      for try await result in decoderStream {
//        if let killMail = result as? [String: Any] {
//          processKillMail(killMail)
//        }
//      }
    } catch {
      print("Error reading from Redis stream: $error)")
    }

  }

  func stopListening() {
    streamTask?.cancel()
  }

  private func processKillMail(_ data: [String: Any]) {
    guard let killID = data["killID"] as? Int,
      let timestamp = data["killTime"] as? String,
      let victim = data["victim"] as? [String: Any],
      let victimName = victim["name"] as? String,
      let victimValue = data["zkb"] as? [String: Any],
      let value = victimValue["totalValue"] as? Int,
      let attackers = data["attackers"] as? [[String: Any]],
      let solarSystemID = data["solarSystemID"] as? Int,
      let shipType = data["shipType"] as? String
    else {
      return
    }

    let attackerNames = attackers.compactMap {
      $0["character"] as? [String: Any]
    }  // or "corporation" if needed
    .compactMap { $0["name"] as? String }

    //        Task {
    //            try await modelContainer.perform {
    //                let kill = KillMail(
    //                    killID: killID,
    //                    timestamp: Date(fromISO8601: timestamp) ?? Date(),
    //                    victimName: victimName,
    //                    victimValue: value,
    //                    attackerNames: attackerNames,
    //                    solarSystemID: solarSystemID,
    //                    shipType: shipType
    //                )
    //                modelContainer.mainContext.insert(kill)
    //            }
    //        }
  }
}
