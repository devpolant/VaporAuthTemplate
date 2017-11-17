//
//  NameValidator.swift
//  App
//
//  Created by Anton Poltoratskyi on 17.11.17.
//  Copyright © 2017 Anton Poltoratskyi. All rights reserved.
//

import Foundation
import Validation

class NameValidator: Validator {
    typealias Input = String
    
    func validate(_ input: String) throws {
        try input
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            .validated(by: Count.min(1))
    }
}
