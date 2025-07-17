//
//  ModelActor.swift
//  EveApp
//
//  Created by Erik Hatfield on 7/16/25.
//

import Foundation
import NIOCore
import NIOPosix

actor ModelActor {
    private let eventLoopGroup: EventLoopGroup
    private let eventLoop: EventLoop
    
    
    init() {
        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.eventLoop = eventLoopGroup.next()
        print("-- RedisActor init")
    }
    
}
