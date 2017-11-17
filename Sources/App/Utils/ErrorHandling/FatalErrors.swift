//
//  FatalErrors.swift
//  App
//
//  Created by Anton Poltoratskyi on 15.11.17.
//  Copyright © 2017 Anton Poltoratskyi. All rights reserved.
//

import Foundation

func notImplemented(_ methodName: String = #function) -> Never {
    fatalError("\(methodName) notImplemented")
}
