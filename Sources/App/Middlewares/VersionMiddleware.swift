//
//  VersionMiddleware.swift
//  App
//
//  Created by Anton Poltoratskyi on 16.11.17.
//  Copyright © 2017 Anton Poltoratskyi. All rights reserved.
//

import HTTP

final class VersionMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)
        
        response.headers["Version"] = "API v1.0"
        
        return response
    }
}
