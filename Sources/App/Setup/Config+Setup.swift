import MySQLProvider
import LeafProvider
import AuthProvider

extension Config {
    public func setup() throws {
        try setupTypeConversions()
        try setupMiddlewares()
        try setupProviders()
        try setupPreparations()
    }
    
    private func setupTypeConversions() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]
    }
    
    private func setupMiddlewares() throws {
        addConfigurable(middleware: VersionMiddleware(), name: "version")
    }
    
    private func setupProviders() throws {
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(User.self)
        preparations.append(UserToken.self)
    }
}
