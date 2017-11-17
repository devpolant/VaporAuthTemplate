//
//  User.swift
//  App
//
//  Created by Anton Poltoratskyi on 15.11.17.
//  Copyright © 2017 Anton Poltoratskyi. All rights reserved.
//

import Vapor
import FluentProvider
import AuthProvider
import HTTP

final class User: Model {
    enum Keys {
        static let id = "id"
        static let name = "name"
        static let email = "email"
        static let password = "password"
        static let avatar = "avatar"
        static let facebookId = "facebook_id"
        static let facebookToken = "facebook_token"
    }
    static let entity: String = "users"
    static let name: String = "user"
    static let idKey: String = "id"
    
    let storage = Storage()
    
    var name: String
    var email: String
    var password: String
    var avatar: String?
    var facebookId: String?
    var facebookToken: String?
    
    init(name: String, email: String, password: String, avatar: String?, facebookId: String? = nil, facebookToken: String? = nil) {
        self.name = name
        self.email = email
        self.password = password
        self.avatar = avatar
        self.facebookId = facebookId
        self.facebookToken = facebookToken
    }
    
    // MARK: RowConvertible
    
    required init(row: Row) throws {
        self.name = try row.get(User.Keys.name)
        self.email = try row.get(User.Keys.email)
        self.password = try row.get(User.Keys.password)
        self.avatar = try row.get(User.Keys.avatar)
        self.facebookId = try row.get(User.Keys.facebookId)
        self.facebookToken = try row.get(User.Keys.facebookToken)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.Keys.id, self.id)
        try row.set(User.Keys.name, self.name)
        try row.set(User.Keys.email, self.email)
        try row.set(User.Keys.password, self.password)
        try row.set(User.Keys.avatar, self.avatar)
        try row.set(User.Keys.facebookId, self.facebookId)
        try row.set(User.Keys.facebookToken, self.facebookToken)
        return row
    }
}

// MARK: - Fluent Preparation

extension User: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(User.self) { builder in
            builder.id()
            builder.string(User.Keys.name)
            builder.string(User.Keys.email, unique: true)
            builder.string(User.Keys.password)
            builder.string(User.Keys.avatar, optional: true)
            builder.string(User.Keys.facebookId, optional: true)
            builder.string(User.Keys.facebookToken, optional: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: - JSON

// How the m odel converts from / to JSON.
// For example when:
//     - Creating a new User (POST /users)
//     - Fetching a user (GET /users, GET /users/:id)
//
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(User.Keys.name),
            email: try json.get(User.Keys.email),
            password: try json.get(User.Keys.password),
            avatar: try json.get(User.Keys.avatar),
            facebookId: try json.get(User.Keys.facebookId),
            facebookToken: try json.get(User.Keys.facebookToken)
        )
        self.id = try json.get(User.Keys.id)
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.Keys.id, id)
        try json.set(User.Keys.name, name)
        try json.set(User.Keys.email, email)
        // try json.set(User.Keys.password, password)
        try json.set(User.Keys.avatar, avatar)
        try json.set(User.Keys.facebookId, facebookId)
        try json.set(User.Keys.facebookToken, facebookToken)
        return json
    }
}

// MARK: - Authentication

extension User: TokenAuthenticatable {
    typealias TokenType = UserToken
}

// MARK: - HTTP

extension User: ResponseRepresentable { }

extension User: Updateable {
    // Updateable keys are called when `user.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<User>] {
        return [
            // If the request contains a key, the setter callback will be called.
            UpdateableKey(User.Keys.name, String.self) { $0.name = $1 },
            UpdateableKey(User.Keys.avatar, String?.self) { $0.avatar = $1 },
            UpdateableKey(User.Keys.facebookId, String?.self) { $0.facebookId = $1 },
            UpdateableKey(User.Keys.facebookToken, String?.self) { $0.facebookToken = $1 }
        ]
    }
}

// MARK: - Request

extension Request {
    func user() throws -> User {
        return try self.auth.assertAuthenticated(User.self)
    }
}
