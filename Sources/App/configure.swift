import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Configure database
    app.databases.use(.postgres(configuration: SQLPostgresConfiguration(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "apimock",
        password: Environment.get("DATABASE_PASSWORD") ?? "password",
        database: Environment.get("DATABASE_NAME") ?? "apimock",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    // Configure Leaf
    app.views.use(.leaf)

    // Add migrations
    app.migrations.add(CreateProject())
    app.migrations.add(CreateEndpoint())
    app.migrations.add(CreateResponse())
    app.migrations.add(CreateRequestRule())

    // register routes
    try routes(app)
}

/**
 command line
 
 docker run --name postgres -e POSTGRES_DB=apimock \
   -e POSTGRES_USER=apimock -e POSTGRES_PASSWORD=password \
   -p 5432:5432 -d postgres
 
 docker-compose down --volumes
 */
