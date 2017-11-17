//
//  PasswordValidator.swift
//  App
//
//  Created by Anton Poltoratskyi on 17.11.17.
//  Copyright © 2017 Anton Poltoratskyi. All rights reserved.
//

import Foundation
import Validation

class PasswordValidator: Validator {
    typealias Input = String
    
    func validate(_ input: Input) throws {
        try input.validated(by: Count.min(6) && Count.max(20))
    }
}
