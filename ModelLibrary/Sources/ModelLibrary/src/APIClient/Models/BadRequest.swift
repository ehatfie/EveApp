//
// BadRequest.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/** Bad request model */

public struct BadRequest: Codable {

    /** Bad request message */
    public var error: String

    public init(error: String) {
        self.error = error
    }


}
