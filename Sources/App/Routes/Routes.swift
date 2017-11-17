import Vapor

extension Droplet {
    func setupRoutes() throws {
        guard let database = database else {
            fatalError("Database not found")
        }
        let authController = AuthController(database: database)
        try collection(authController)
    }
}

