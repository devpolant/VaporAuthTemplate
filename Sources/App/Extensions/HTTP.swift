//
//  HTTP.swift
//  App
//
//  Created by Anton Poltoratskyi on 16.11.17.
//  Copyright © 2017 Anton Poltoratskyi. All rights reserved.
//

import HTTP

extension HTTP.KeyAccessible where Key == HeaderKey, Value == String {
    
    var token: String? {
        get { return self["token"] }
        set { self["token"] = newValue }
    }
}
