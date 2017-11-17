//
//  UserToken.swift
//  App
//
//  Created by Anton Poltoratskyi on 16.11.17.
//  Copyright © 2017 Anton Poltoratskyi. All rights reserved.
//

import Vapor
import FluentProvider
import Crypto
import BCrypt

final class UserToken: Model {
    enum Keys {
        static let token = "token"
        static let userId = User.foreignIdKey
    }
    static let entity: String = "\(User.name)_tokens"
    
    let storage = Storage()
    
    let tokenString: String
    let userId: Identifier
    
    init(string: String, user: User) throws {
        self.tokenString = string
        self.userId = try user.assertExists()
    }
    
    // MARK: RowConvertible
    
    init(row: Row) throws {
        self.tokenString = try row.get(UserToken.Keys.token)
        self.userId = try row.get(UserToken.Keys.userId)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(UserToken.Keys.token, tokenString)
        try row.set(UserToken.Keys.userId, userId)
        return row
    }
}

// MARK: - Convenience

extension UserToken {
    static func generate(for user: User) throws -> UserToken {
        // generate 128 random bits using OpenSSL
        let random = try Crypto.Random.bytes(count: 16)
        return try UserToken(string: random.base64Encoded.makeString(), user: user)
    }
}

// MARK: - Relations

extension UserToken {
    var user: Parent<UserToken, User> {
        return parent(id: userId)
    }
}

// MARK: - Fluent Preparation

extension UserToken: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(UserToken.self) { builder in
            builder.id()
            builder.string(UserToken.Keys.token)
            builder.foreignId(for: User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSON

extension UserToken: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("token", tokenString)
        return json
    }
}

// MARK: - HTTP

extension UserToken: ResponseRepresentable { }
