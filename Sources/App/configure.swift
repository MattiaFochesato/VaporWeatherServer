import Vapor
import Leaf

/** Configures your Vapor application */
public func configure(_ app: Application) throws {
    /// Uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    /// Enable Leaf support. Used to show the index page
    app.views.use(.leaf)
    
    /// Register routes
    try routes(app)
}
