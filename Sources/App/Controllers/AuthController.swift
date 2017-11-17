//
//  AuthController.swift
//  App
//
//  Created by Anton Poltoratskyi on 15.11.17.
//  Copyright © 2017 Anton Poltoratskyi. All rights reserved.
//

import Foundation
import Vapor
import Fluent
import HTTP
import BCrypt
import Validation

final class AuthController: RouteCollection {
    
    private let database: Database
    
    init(database: Database) {
        self.database = database
    }
    
    func build(_ builder: RouteBuilder) throws {
        builder.group("auth") { setupRoutes(for: $0) }
    }
    
    private func setupRoutes(for builder: RouteBuilder) {
        builder.post("login", handler: self.login)
        builder.post("signup", handler: self.signup)
    }
    
    // MARK: - Routes
    
    private func login(_ req: Request) throws -> ResponseRepresentable {
        guard let credentials = req.loginCredentials else {
            throw Abort(.badRequest)
        }
        do { try credentials.email.validated(by: EmailValidator()) }
        catch { return try Response.error(message: "Invalid email") }
        
        do { try credentials.password.validated(by: PasswordValidator()) }
        catch { return try Response.error(message: "Invalid password") }
        
        do {
            return try database.transaction { connection -> ResponseRepresentable in
                guard let user = try User.makeQuery().filter(User.Keys.email, .equals, credentials.email).first() else {
                    return try Response.error(message: "User with email not exists")
                }
                
                guard try self.verify(hash: user.password, mathes: credentials.password) else {
                    return try Response.error(message: "Invalida email or password")
                }
                let token = try UserToken.generate(for: user)
                try token.makeQuery(connection).save()
                
                return try authenticationResponse(for: user, token: token)
            }
        } catch {
            throw Abort(.internalServerError)
        }
    }
    
    private func signup(_ req: Request) throws -> ResponseRepresentable {
        guard let credentials = req.signUpCredentials else {
            throw Abort(.badRequest)
        }
        
        do { try credentials.name.validated(by: NameValidator()) }
        catch { return try Response.error(message: "Invalid name") }
        
        do { try credentials.email.validated(by: EmailValidator()) }
        catch { return try Response.error(message: "Invalid email") }
        
        do { try credentials.password.validated(by: PasswordValidator()) }
        catch { return try Response.error(message: "Invalid password") }
        
        do {
            return try database.transaction { connection -> ResponseRepresentable in
                guard try User.makeQuery().filter(User.Keys.email, .equals, credentials.email).first() == nil else {
                    return try Response.error(message: "User with email already exists")
                }
                let hash = try self.hash(for: credentials.password)
                
                let user = User(name: credentials.name, email: credentials.email, password: hash, avatar: nil)
                try user.makeQuery(connection).save()
                
                let token = try UserToken.generate(for: user)
                try token.makeQuery(connection).save()
                
                return try authenticationResponse(for: user, token: token)
            }
        } catch {
            throw Abort(.internalServerError)
        }
    }
    
    
    // MARK: - Response
    
    private func authenticationResponse(for user: User, token: UserToken) throws -> ResponseRepresentable {
        var result = JSON()
        try result.set("error", false)
        try result.set("user", try user.makeJSON())
        try result.set("access-token", token.tokenString)
        return result
    }
    
    
    // MARK: - Crypto
    
    private func hash(for password: String) throws -> String {
        let hashBytes = try BCrypt.Hash.make(message: password)
        return String(data: Data(bytes: hashBytes), encoding: .utf8)!
    }
    
    private func verify(hash: String, mathes inputPassword: String) throws -> Bool {
        let hashBytes = hash.data(using: .utf8)!.makeBytes()
        return try BCrypt.Hash.verify(message: inputPassword, matches: hashBytes)
    }
}


// MARK: - Credentials

fileprivate extension Request {
    
    var loginCredentials: LoginCredentials? {
        guard let email = data["email"]?.string, let password = data["password"]?.string else {
            return nil
        }
        return LoginCredentials(email: email, password: password)
    }
    
    var signUpCredentials: SignUpCredentials? {
        guard let name = data["name"]?.string,
            let email = data["email"]?.string,
            let password = data["password"]?.string else {
                return nil
        }
        return SignUpCredentials(name: name, email: email, password: password)
    }
}
