//
//  ResponseRepresentable.swift
//  App
//
//  Created by Anton Poltoratskyi on 17.11.17.
//  Copyright © 2017 Anton Poltoratskyi. All rights reserved.
//

import HTTP

extension ResponseRepresentable {
    static func error(message: String) throws -> ResponseRepresentable {
        var json = JSON()
        try json.set("error", true)
        try json.set("message", message)
        return json
    }
}
