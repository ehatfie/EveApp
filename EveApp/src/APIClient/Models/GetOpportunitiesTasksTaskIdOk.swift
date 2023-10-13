//
// GetOpportunitiesTasksTaskIdOk.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** 200 ok object */

public struct GetOpportunitiesTasksTaskIdOk: Codable {

    /** description string */
    public var _description: String
    /** name string */
    public var name: String
    /** notification string */
    public var notification: String
    /** task_id integer */
    public var taskId: Int

    public init(_description: String, name: String, notification: String, taskId: Int) {
        self._description = _description
        self.name = name
        self.notification = notification
        self.taskId = taskId
    }

    public enum CodingKeys: String, CodingKey { 
        case _description = "description"
        case name
        case notification
        case taskId = "task_id"
    }

}
