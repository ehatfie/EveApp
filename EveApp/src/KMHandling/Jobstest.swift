////
////  Jobstest.swift
////  EveApp
////
////  Created by Erik Hatfield on 7/15/25.
////
//
//import Queues
//import QueuesRedisDriver
//
//struct EmailJob: AsyncJob {
//    typealias Payload = Email
//
//    func dequeue(_ context: QueueContext, _ payload: Email) async throws {
//        // This is where you would send the email
//        print("Email Job Dequeue")
//        
//        //while true {
//            let response = try await context.application.client.get("https://redisq.zkillboard.com/listen.php?queueID=YourIdHere2q3")
//            let decoder = JSONDecoder()
//            
//            let data = Data(buffer: response.body!, byteTransferStrategy: .automatic)
//            do {
//                let object = try decoder.decode(ZKillFeedResponseWrapper.self, from: data)
//               // context.application.post
//                print("email job got \(object.package.killID)")
//                try await context.application.queues.queue.dispatch(
//                    ModelJob.self,
//                    object
//                )
//                //print("got object \(object)")
//            } catch let err {
//                print("Decode error \(err)")
//            }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
//            try? context.application.queues.queue.dispatch(
//                EmailJob.self,
//                .init(to: "foo@bar.com", message: "Hello World!")
//            ).wait()
//        }
//
//        //}
//    }
//
//    func error(_ context: QueueContext, _ error: Error, _ payload: Email) async throws {
//        // If you don't want to handle errors you can simply return. You can also omit this function entirely.
//        print("Emaiol job error")
//    }
//}
//
//struct ModelJob: AsyncJob {
//    typealias Payload = ZKillFeedResponseWrapper
//    
//    func dequeue(_ context: QueueContext, _ payload: Payload) async throws {
//        let model = ESIKillmailModel(data: payload.package.killmail)
//        
//        do {
//            try await model.save(on: context.application.db)
//            print("saved \(model.killmailId)")
//        } catch let err {
//            print("MJ error \(String(reflecting:err))")
//        }
//       
//    }
//
//    func error(_ context: QueueContext, _ error: Error, _ payload: Email) async throws {
//        // If you don't want to handle errors you can simply return. You can also omit this function entirely.
//        print("Model job error" + String(reflecting: error))
//    }
//}
